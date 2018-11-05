#Python V3.5.2

import serial
import tkinter as tk
import time

while(1):
    try:
        port = "com" + str(int(input(">  COM: ")))
        break
    except:
        print ("Enter a numeric value")

data = serial.Serial(port, baudrate = 9600, timeout=1500)

def refresh(x):
    result = None
    data.reset_input_buffer()
    time.sleep(.5)
    while(result is None):
        result = data.readline()
    print(type(result))
    return(result)

class Mainframe(tk.Frame):
    
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        tk.Label(self, text = "Angulo", font=("Courier", 15)).place(x = 40, y = 30)
        
        self.spBox = tk.Spinbox(self, from_=0, to=180, font=("Courier", 13))
        self.spBox.place(x = 20, y = 70, width = 120)
        
        self.Temperature = tk.IntVar()
        tk.Label(self,textvariable = self.Temperature, font=("Courier", 15)).place(x = 180, y = 30)
        self.TimerInterval = 500

        tk.Button(self, text = "Enviar", command = self.send, font=("Courier", 15)).place(x = 180, y = 65)
        
        self.Temp = 0
        
        self.GetTemp()
        
    def GetTemp(self):
        self.Temperature.set(self.Temp)
        self.Temp += 1
        
        # Now repeat call
        self.after(self.TimerInterval,self.GetTemp)

    def send(self):
        data.write(bytes(self.spBox.get().encode()))
        data.write(b'\n')

class leftFrame(tk.Frame):
    
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        tk.Label(self, text = "Voltaje", font=("Courier", 15)).place(x = 20, y = 30)
        
        self.Voltaje = tk.IntVar()
        tk.Label(self,textvariable = self.Voltaje, font=("Courier", 13)).place(x = 55, y = 70)

        self.TimerInterval = 500

        self.Volt = 1

        self.refreshVoltaje()

    def refreshVoltaje(self):
        self.Volt = refresh(self.Volt)
        self.Voltaje.set(self.Volt)

        self.after(self.TimerInterval,self.refreshVoltaje)

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)
               
        self.title('Miniproyecto de Microcontroladores')
        self.geometry('450x200')

        leftFrame(self).place(x = 20, y = 30, width=150, height=300)
        Mainframe(self).place(x = 160, y = 30, width=300, height=300)
        self.mainloop()
    
App()
