#Python V3.5.2

#Use arduino's TestingSketch for testing purpose

import serial
import tkinter as tk
import tkinter.ttk as ttk

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)

        self.config(bg="dark slate gray")   #Add BG color to window
               
        self.title('Miniproyecto de Microcontroladores')    #Window's title
        self.geometry('700x400')                            #Window's size
        self.resizable(False, False)                        #Not resizable cuz' not responsive designed

        self.vals = []
        self.cBox = ttk.Combobox(self, values = self.vals, postcommand = self.update)
        self.cBox.pack()
        tk.Button(self, text = "Agregar", command = self.send, font=("MS Serif", 13), bg="black", fg="white", width=10, height=2).place(x = 310, y = 310)
        self.mainloop()

    def update(self):
        self.cBox['values'] = self.vals
        
    def send(self):
        self.vals.append("Hehe")
        print(self.vals)
    
App()
