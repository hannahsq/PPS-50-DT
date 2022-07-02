import re
import os
from sys import platform

def disassemble(info_filename, output_filename):
    jumplike = re.compile(r'([ \t]{2,}(?:RTI|RTS|PUL|JMP|BRA|SWI|hdlr_NMI)[ ]+.*)((?:\r?\n)+)')
    jumplike_subs = r'\1\n\n'
    returns = re.compile(r'([ \t]{2,}(?:RTI|RTS)[ ]+.*)((?:\r?\n)+)')
    returns_subs = r'\1\n\n;-------------------------------------------------------------------------------\n\n'
    temp_filename = "1.temp"
    cmd = dasm + " -info " + info_filename + " -out " + temp_filename

    print(cmd)
    os.system(cmd)

    with open(temp_filename,"r") as f:
        with open(output_filename,"w") as g:
            for line in f:
                g.write(returns.sub(returns_subs , jumplike.sub(jumplike_subs, line)))
                
    os.remove(temp_filename)


primary_controller_info_filename = "primary_controller.info"
primary_controller_output_filename = "primary_controller.asm"
gpib_controller_info_filename = "gpib_controller.info"
gpib_controller_output_filename = "gpib_controller.asm"
dasm = "f9dasm"

if platform == "win32":
    dasm = "..\\..\\tools\\" + dasm + ".exe"
else:
    dasm = "../../tools/" + dasm

disassemble(primary_controller_info_filename, primary_controller_output_filename)

disassemble(gpib_controller_info_filename, gpib_controller_output_filename)
