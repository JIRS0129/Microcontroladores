#Python V3.5.2

#Use arduino's TestingSketch for testing purpose

#Library imports
import tkinter as tk
import tkinter.ttk as ttk
import serial
import time
import os

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


bgColor = "cyan"

def refreshSerial(first):
    result = None
    if(first):
        while(result is None):
            result = ord(data.readline(1))
        return(result)
    
    #data.reset_input_buffer()
    
    while(result is None):
        print(str(progressRecord.winfo_ismapped()) + "  " + str(data.in_waiting) + "  " + str(amountMissing.get()))
        if(not(progressRecord.winfo_ismapped()) and not(data.in_waiting)):
            return(0)
        if(progressRecord.winfo_ismapped()):
            print("Fetching")
        result = data.readline(1)
    result = ord(result)
    print(result)
    return(result)

class refreshFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        global amountMissing
        amountMissing = tk.IntVar()
        amountMissing.set(0)

        global first
        first = tk.BooleanVar()
        first.set(True)

        #Timer interval (us)
        self.TimerInterval = 1
        #Calling timer function
        self.refresh()
        
        
    def refresh(self):
        
        if(recording.get()):
            print("Refreshing")
            if(progressRecord.winfo_ismapped()):
                progressbar.step(100/amountMissing.get())
                print("Step")
                if(not(data.in_waiting)):
                    progressRecord.place_forget()
                    print("Rid of preogress record")
            if(first.get()):
                print(refreshSerial(first.get()))
                first.set(False)
            #Save incoming data to internal db
            file = open(rName.get() + ".txt","a")
            in_num = refreshSerial(first.get())
            if(in_num != 0):
                file.write("%d\n" % (in_num))
            file.close()

        # Now repeat call
        self.after(self.TimerInterval,self.refresh)

class leftFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        #Recording feedback image
        self.path = "Rec.png"    #Define image path
        self.background_image=tk.PhotoImage(file = self.path)   #Create variable with image
        self.lbl = tk.Label(self, image=self.background_image, width=50, height=10, bg=bgColor) #Initialize label with image

        self.initRecord = tk.BooleanVar()
        self.initRecord.set(False)

        global progressRecord
        progressRecord = ttk.Progressbar(self, maximum=100)

        global rName         #Name of current Routine
        rName = tk.StringVar()
        rName.set("")

        #Global var to determine if currently recording
        global recording
        recording = tk.BooleanVar()
        recording.set(False)
#TEST
        self.count = tk.IntVar()
        self.count.set(1)

        self.config(bg=bgColor, bd=2, relief="solid")   #Add aesthetics to frame

        tk.Label(self, text = "Routine name", font=("MS Serif", 10), bg=bgColor, fg="black").place(x = 40, y = 25)
        self.name = tk.StringVar()
        tk.Entry(self, textvariable = self.name).place(x = 40, y = 45)

        global recButton
        recButton = tk.Button(self, text = "Start Recording", command = self.record, font=("MS Serif", 13), bg="green", fg="white", width=12, height=2)
        recButton.place(x = 45, y = 150)

    def record(self):
        Error.set("")   #Reset error's message
        if(self.name.get() != ""):
            if(not(recording.get())):
                amountMissing.set(1)
                print("Recording")
                recording.set(True)     #Set that recording
                button.config(state = "disabled", bg = "grey64", text = "Recording")
                recButton['text']  ='Stop Recording'       #Change button's properties
                recButton['bg'] = 'red'
                rName.set(self.name.get())            #Change var's value
                file = open(rName.get() + ".txt","w+")   #Open and clear file
                file.write("")
                file.close()

                #send 1
                self.sending = 1
                self.sending = chr(self.sending)
            
                data.write(bytes(self.sending.encode()))

                while(not(data.in_waiting)):
                    print("waiting")
                
                #Timer interval (us)
                self.TimerInterval = 500
                #Calling timer function
                self.receive()

                self.initRecord.set(True)
                print("Out first click")
            else:

                #send 1
                self.sending = 0
                self.sending = chr(self.sending)
                
                data.write(bytes(self.sending.encode()))
                print("0 sent")
                
                progressRecord.place(x = 0, y = 0, width = 215)
                print("progress Record Placed")
                

                amountMissing.set(data.in_waiting)
                print(amountMissing.get())
                
        else:   #If no name entered
            Error.set("Please, enter a valid name")

    def receive(self):
###############################################################################
        
        if(recording.get()):
            if(not(progressRecord.winfo_ismapped()) and not(data.in_waiting) ):
                print("stoping")
                first.set(True)
                amountMissing.set(0)
                button.config(state = "active", bg = "green", text = "Play")
                self.lbl.place_forget()     #Reset the recording feedback image
                    
                recording.set(False)        #Set that not recording
                recButton['text'] = 'Start Recording'  #Change button's properties
                recButton['bg'] = 'green'
            
            if(len(self.lbl.place_info())):
                self.lbl.place_forget()
            else:
                self.lbl.place(x = 192, y = 0, width=40, height=20)

            # Now repeat call
            self.after(self.TimerInterval,self.receive)


class rightFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        self.TimerInterval = 5

        global instructions
        instructions = []

        global amount
        amount = tk.IntVar()
        amount.set(0)

        self.config(bg=bgColor, bd=2, relief="solid")   #Add BG color to frame
        
        tk.Label(self, text = "Select routine", font=("MS Serif", 10), bg=bgColor, fg="black").place(x = 40, y = 25)

        self.vals  = [""]
        self.cBox = ttk.Combobox(self, values = self.vals, postcommand = self.update, state="readonly")
        self.cBox.place(x = 40, y = 45)

        global progressbar
        progressbar = ttk.Progressbar(self, maximum=100)

        global button
        button = tk.Button(self, text = "Play", command = self.play, font=("MS Serif", 13), bg="green", fg="white", width=10, height=2)
        button.place(x = 60, y = 150)

        self.refresh()


    def update(self):
        self.vals = [x for x in os.listdir() if 'txt' in x]
        self.cBox['values'] = self.vals

    def play(self):
        Error.set("")
        if(self.cBox.get() == ""):
            Error.set("Seleccione una rutina a ejecutar")
        else:
            button.config(state = "disabled", bg = "grey64", text = "Playing")
            recButton.config(state = "disabled", bg = "grey64", text = "Playing")
            progressbar.place(x = 10, y = 100, width = 215)
            file = open(self.cBox.get(),"r")
            print(self.cBox.get())
            content = file.read()
            file.close()

            amount.set(content.count('\n'))

            #send 2
            self.sending = 2
            self.sending = chr(self.sending)
        
            data.write(bytes(self.sending.encode()))
            
            while(content.count('\n')):
                instructions.append(content[:content.find('\n')])
                content = content[content.find('\n') + 1:]

    def refresh(self):

        if(progressbar.winfo_ismapped()):
            #print(instructions[0])
            print(len(instructions))
            if(len(instructions)):
            #Reading angle and conversion
                self.sending = int(instructions.pop(0))
                self.sending = chr(self.sending)

                progressbar.step(100/amount.get())
            
                data.write(bytes(self.sending.encode()))
                if not(len(instructions)):
                    progressbar.place_forget()
                    button.config(state = "active", bg = "green", text = "Play")
                    recButton.config(state = "active", bg = "green", text = "Start Recording")
                    #send 1
                    self.sending = 0
                    self.sending = chr(self.sending)

                    x = 1
                    while(x <= 5):
                        data.write(bytes(self.sending.encode()))
                        x += 1
        
        # Now repeat call
        self.after(self.TimerInterval,self.refresh)                

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)

        self.config(bg=bgColor)   #Add BG color to window

        self.title('Proyecto de Microcontroladores')    #Window's title
        self.geometry('700x400')                            #Window's size
        self.resizable(False, False)                        #Not resizable cuz' not responsive designed

        tk.Label(self, text = "Proyecto (Brazo)", font=("MS Serif", 13), bg=bgColor).place(x = 180, y = 15)
        tk.Label(self, text = "Por: Alejandro Recancoj y José Ramírez", font=("MS Serif", 9), bg=bgColor).place(x = 155, y = 45)

        leftFrame(self).place(x = 10, y = 100, height = 230, width = 240)
        rightFrame(self).place(x = 240, y = 100, height = 230, width = 240)
        refreshFrame(self).place(x = 0, y = 0)

        tk.Label(self, text = "Record", font=("MS Serif", 12), bg=bgColor, fg="black").place(x = 50, y = 85)
        tk.Label(self, text = "Play", font=("MS Serif", 12), bg=bgColor, fg="black").place(x = 275, y = 85)

        global Error
        Error = tk.StringVar()
        Error.set("error")
        tk.Label(self, textvariable = Error, font=("MS Serif", 10), bg=bgColor, fg="black", borderwidth = 5).place(x = 0, y = 350, height = 50, width = 300)
        
        self.mainloop()

App()
