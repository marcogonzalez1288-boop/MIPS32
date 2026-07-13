import tkinter as tk
from tkinter import filedialog, messagebox
import re

class MIPSAssembler:
    def __init__(self):
        # Diccionarios escalables para agregar nuevas instrucciones
        self.R_TYPE = {
            'nop': 0x00, 'add': 0x20, 'sub': 0x22, 
            'and': 0x24, 'or': 0x25, 'slt': 0x2A
        }
        self.I_TYPE = {
            'addi': 0x08, 'andi': 0x0C, 'ori': 0x0D, 
            'slti': 0x0A, 'beq': 0x04, 'lw': 0x23, 'sw': 0x2B
        }
        self.J_TYPE = {
            'j': 0x02
        }
        
        # Mapeo de registros estándar
        self.REGISTERS = {
            '$zero': 0, '$at': 1, '$v0': 2, '$v1': 3,
            '$a0': 4, '$a1': 5, '$a2': 6, '$a3': 7,
            '$t0': 8, '$t1': 9, '$t2': 10, '$t3': 11, '$t4': 12, '$t5': 13, '$t6': 14, '$t7': 15,
            '$s0': 16, '$s1': 17, '$s2': 18, '$s3': 19, '$s4': 20, '$s5': 21, '$s6': 22, '$s7': 23,
            '$t8': 24, '$t9': 25, '$k0': 26, '$k1': 27,
            '$gp': 28, '$sp': 29, '$fp': 30, '$ra': 31
        }

    def reg_to_bin(self, reg_str):
        if reg_str not in self.REGISTERS:
            raise ValueError(f"Registro inválido: {reg_str}")
        return f"{self.REGISTERS[reg_str]:05b}"

    def imm_to_bin(self, imm_str, bits=16):
        try:
            imm = int(imm_str)
            # Manejo de complemento a 2 para negativos
            if imm < 0:
                imm = (1 << bits) + imm
            return f"{imm:0{bits}b}"
        except ValueError:
            raise ValueError(f"Inmediato inválido: {imm_str}")

    def assemble(self, code_text):
        lines = code_text.split('\n')
        instructions = []
        labels = {}
        
        # PRIMERA PASADA: Limpiar código y encontrar etiquetas
        pc = 0
        for line_num, line in enumerate(lines):
            # Quitar comentarios y espacios
            line = line.split('#')[0].strip()
            if not line:
                continue
                
            # Buscar etiquetas (ej. "ciclo:")
            if ':' in line:
                label, rest = line.split(':', 1)
                labels[label.strip()] = pc
                line = rest.strip()
                if not line:
                    continue
            
            instructions.append((pc, line_num + 1, line))
            pc += 1 # Cada instrucción vale 1 PC (en líneas)

        binary_output = []

        # SEGUNDA PASADA: Traducir a binario
        for pc, line_num, instr_line in instructions:
            try:
                # Separar instrucción de argumentos
                parts = re.split(r'[\s,]+', instr_line)
                mnem = parts[0].lower()
                args = parts[1:]

                if mnem in self.R_TYPE:
                    if mnem == 'nop':
                        binary_output.append("00000000000000000000000000000000")
                    else:
                        if len(args) != 3: raise ValueError("R-Type requiere 3 argumentos")
                        rd, rs, rt = args[0], args[1], args[2]
                        rs_bin = self.reg_to_bin(rs)
                        rt_bin = self.reg_to_bin(rt)
                        rd_bin = self.reg_to_bin(rd)
                        funct_bin = f"{self.R_TYPE[mnem]:06b}"
                        binary_output.append(f"000000{rs_bin}{rt_bin}{rd_bin}00000{funct_bin}")

                elif mnem in self.I_TYPE:
                    op_bin = f"{self.I_TYPE[mnem]:06b}"
                    
                    # Manejo especial para LW y SW (ej. lw $t0, 4($sp))
                    if mnem in ['lw', 'sw']:
                        if len(args) != 2: raise ValueError("LW/SW requiere 2 argumentos")
                        rt = args[0]
                        # Extraer offset y registro base
                        match = re.match(r'(-?\d+)\((.+)\)', args[1])
                        if not match: raise ValueError("Formato de memoria inválido")
                        imm, rs = match.groups()
                        
                        rs_bin = self.reg_to_bin(rs)
                        rt_bin = self.reg_to_bin(rt)
                        imm_bin = self.imm_to_bin(imm, 16)
                        binary_output.append(f"{op_bin}{rs_bin}{rt_bin}{imm_bin}")
                        
                    # Manejo especial para BEQ
                    elif mnem == 'beq':
                        if len(args) != 3: raise ValueError("BEQ requiere 3 argumentos")
                        rs, rt, label = args[0], args[1], args[2]
                        rs_bin = self.reg_to_bin(rs)
                        rt_bin = self.reg_to_bin(rt)
                        
                        if label not in labels: raise ValueError(f"Etiqueta no encontrada: {label}")
                        # Offset relativo a PC+1
                        offset = labels[label] - (pc + 1)
                        imm_bin = self.imm_to_bin(str(offset), 16)
                        binary_output.append(f"{op_bin}{rs_bin}{rt_bin}{imm_bin}")
                        
                    # Aritméticas/Lógicas I-Type (ADDI, ANDI, ORI, SLTI)
                    else:
                        if len(args) != 3: raise ValueError(f"{mnem.upper()} requiere 3 argumentos")
                        rt, rs, imm = args[0], args[1], args[2]
                        rs_bin = self.reg_to_bin(rs)
                        rt_bin = self.reg_to_bin(rt)
                        imm_bin = self.imm_to_bin(imm, 16)
                        binary_output.append(f"{op_bin}{rs_bin}{rt_bin}{imm_bin}")

                elif mnem in self.J_TYPE:
                    if len(args) != 1: raise ValueError("J requiere 1 argumento")
                    label = args[0]
                    if label not in labels: raise ValueError(f"Etiqueta no encontrada: {label}")
                    
                    op_bin = f"{self.J_TYPE[mnem]:06b}"
                    addr_bin = self.imm_to_bin(str(labels[label]), 26)
                    binary_output.append(f"{op_bin}{addr_bin}")

                else:
                    raise ValueError(f"Instrucción no soportada: {mnem}")

            except Exception as e:
                raise Exception(f"Error en la línea {line_num} ('{instr_line}'): {str(e)}")

        return "\n".join(binary_output)


class AssemblerGUI:
    def __init__(self, root):
        self.assembler = MIPSAssembler()
        self.root = root
        self.root.title("Decodificador MIPS32 - Verano 2026")
        self.root.geometry("600x500")

        # Barra de botones
        btn_frame = tk.Frame(root)
        btn_frame.pack(pady=10)

        tk.Button(btn_frame, text="Abrir Archivo (.txt)", command=self.load_file).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Ensamblar Código", command=self.assemble_code, bg="lightblue").pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Guardar Binario", command=self.save_file).pack(side=tk.LEFT, padx=5)

        # Cajas de texto
        tk.Label(root, text="Código Ensamblador (MIPS):").pack(anchor=tk.W, padx=20)
        self.text_in = tk.Text(root, height=12, width=70)
        self.text_in.pack(pady=5)

        tk.Label(root, text="Salida Binaria (Verilog $readmemb):").pack(anchor=tk.W, padx=20)
        self.text_out = tk.Text(root, height=12, width=70, state=tk.DISABLED)
        self.text_out.pack(pady=5)

    def load_file(self):
        filepath = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")])
        if filepath:
            with open(filepath, 'r', encoding='utf-8') as file:
                self.text_in.delete("1.0", tk.END)
                self.text_in.insert(tk.END, file.read())

    def assemble_code(self):
        code = self.text_in.get("1.0", tk.END)
        try:
            binary = self.assembler.assemble(code)
            
            self.text_out.config(state=tk.NORMAL)
            self.text_out.delete("1.0", tk.END)
            self.text_out.insert(tk.END, binary)
            self.text_out.config(state=tk.DISABLED)
            
            messagebox.showinfo("Éxito", "¡Ensamblado correctamente!")
        except Exception as e:
            messagebox.showerror("Error de Sintaxis", str(e))

    def save_file(self):
        binary = self.text_out.get("1.0", tk.END).strip()
        if not binary:
            messagebox.showwarning("Advertencia", "No hay código binario para guardar.")
            return
            
        filepath = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text Files", "*.txt")])
        if filepath:
            with open(filepath, 'w') as file:
                file.write(binary)
            messagebox.showinfo("Guardado", f"Binario guardado en:\n{filepath}")

if __name__ == "__main__":
    root = tk.Tk()
    app = AssemblerGUI(root)
    root.mainloop()