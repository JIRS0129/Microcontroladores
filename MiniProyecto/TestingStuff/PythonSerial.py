import serial
import tkinter

while(1):
    try:
        port = "com" + str(int(input(">  COM: ")))
        break
    except:
        print ("Enter a numeric value")

data = serial.Serial(port, 9600)

def C_1():
    data.write(b'Command1\n')

def C_2():
    data.write(b'Command2\n')

def C_3():
    data.write(b'Command3\n')

window = tkinter.Tk()

button = tkinter.Button
label = tkinter.Label

btn1 = button(window, text = "Command 1", command = C_1)
btn2 = button(window, text = "Command 2", command = C_2)
btn3 = button(window, text = "Command 3", command = C_3)

vLBL = label(window, text="Hello, world!")

btn1.grid(row=0, column=0)
btn2.grid(row=0, column=1)
btn3.grid(row=0, column=2)
vLBL.grid(row=1, column=1)
window.mainloop()
