#Python V3.5.2

#Use arduino's TestingSketch for testing purpose

import serial
import tkinter as tk
import time

while(1):
    while(1):
        try:
            port = "com" + str(int(input(">  COM: ")))  #COM input
            break
        except:
            print ("Enter a numeric value")             #Error if not valid number
    try:
        data = serial.Serial(port, baudrate = 9600, timeout=1500)   #Open serial port
        break
    except:
        print("Unable to open port")                    #Error if port error/timeout

def refresh():
    result = None
    data.reset_input_buffer()
    time.sleep(.1)
    while(result is None):
        result = data.readline(1)
    result = ord(result)
    print(result)
    return(result)

class Arrow2(tk.Frame):
    
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)
        
        self.path = "arrow1.PNG"    #Define image path
        self.background_image=tk.PhotoImage(file = self.path)   #Create variable with image
        tk.Label(self, image=self.background_image, width=125, height=70, bg="dark slate gray").pack() #Initialize label with image
        #self.configure(image = self.background_image)

class Arrow1(tk.Frame):
    
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)
        
        self.path = "arrow2.PNG"    #Define image path
        self.background_image=tk.PhotoImage(file = self.path)   #Create variable with image
        tk.Label(self, image=self.background_image, width=125, height=70, bg="dark slate gray").pack() #Initialize label with image
        #self.configure(image = self.background_image)

class Mainframe(tk.Frame):
    
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        self.config(bg="dark slate gray")   #Add BG color to frame

        #Title and authors' labels
        tk.Label(self, text = "Miniproyecto (Comunicación Serial)", font=("MS Serif", 15), bg="dark slate gray", fg = "white").place(x = 200, y = 30)

        tk.Label(self, text = "Por: Alejandro Recancoj y José Ramírez", font=("MS Serif", 15), bg="dark slate gray", fg = "white").place(x = 180, y = 70)

        tk.Label(self, text = "Ayuda para diseño: Christian Gonzalez", font=("MS Serif", 11), bg="dark slate gray", fg = "white").place(x = 5, y = 370)

        #Static labels
        tk.Label(self, text = "Voltaje", font=("MS Serif", 13), bg="white", borderwidth=3, relief="solid", width=10, height=2).place(x = 150, y = 150)

        tk.Label(self, text = "Ángulo", font=("MS Serif", 13), bg="white", borderwidth=3, relief="solid", width=10, height=2).place(x = 150, y = 230)

        #Button
        tk.Button(self, text = "Enviar", command = self.send, font=("MS Serif", 13), bg="black", fg="white", width=10, height=2).place(x = 310, y = 310)

        #Arrows for aesthetic purpose
        Arrow1(self).place(x = 300, y = 135)
        Arrow2(self).place(x = 300, y = 215)

        #Variable label
        self.Voltaje = tk.IntVar()
        tk.Label(self,textvariable = self.Voltaje, font=("MS Serif", 13), bg="dark slate gray", borderwidth=3, relief="solid", width=10, height=2, fg="white").place(x = 500, y = 150)

        self.Error = tk.StringVar()
        self.Error.set("")
        tk.Label(self,textvariable = self.Error, font=("MS Serif", 13), bg="dark slate gray", fg="white").place(x = 300, y = 370)

        #Angle input
        self.spBox = tk.Spinbox(self, from_=0, to=180, font=("MS Serif", 13))
        self.spBox.place(x = 500, y = 240, width = 100, height = 30)

        #Timer interval (us)
        self.TimerInterval = 5
        #Calling timer function
        self.GetTemp()
        
    def GetTemp(self):
        #Convert what's comming on serial
        self.Volt = refresh()
        self.Volt = round(((self.Volt * 5)/255),3)
        self.Voltaje.set(self.Volt)
        # Now repeat call
        self.after(self.TimerInterval,self.GetTemp)
        
    def send(self):
        #Checking if angle in valid range
        try:
            int(self.spBox.get())
        except:
            self.Error.set("Error")
            return
        if(not(int(self.spBox.get()) <= 180  and int(self.spBox.get()) >= 0)):
            self.Error.set("Error: ángulo invalido")
        else:
            #Reading angle and conversion
            self.sending = int(self.spBox.get())
            self.sending = round(self.sending * 119 / 180, 0) + 41
            self.sending = int(self.sending)
            self.sending = chr(self.sending)
            
            data.write(bytes(self.sending.encode()))
            self.Error.set("")
        

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)

        self.config(bg="dark slate gray")   #Add BG color to window
               
        self.title('Miniproyecto de Microcontroladores')    #Window's title
        self.geometry('700x400')                            #Window's size
        self.resizable(False, False)                        #Not resizable cuz' not responsive designed

        Mainframe(self).place(x = 10, y = 10, width=700, height=500)    #Mainframe creation
        tk.Label(self, text = "V", font=("MS Serif", 13), bg="dark slate gray", fg="white").place(x = 580, y = 170) #Label for units 
        self.mainloop()
    
App()
