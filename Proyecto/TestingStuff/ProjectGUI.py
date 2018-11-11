#Python V3.5.2

#Use arduino's TestingSketch for testing purpose

import tkinter as tk
import tkinter.ttk as ttk
import time

class leftFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        global recording
        recording = tk.BooleanVar()
        recording.set(False)

        self.count = 1

        self.config(bg="cyan", bd=2, relief="solid")   #Add BG color to frame

        tk.Label(self, text = "Routine name", font=("MS Serif", 10), bg="cyan", fg="black").place(x = 10, y = 25)
        self.name = tk.StringVar()
        tk.Entry(self, textvariable = self.name).place(x = 10, y = 45)

        self.recButton = tk.Button(self, text = "Start Recording", command = self.record, font=("MS Serif", 13), bg="green", fg="white", width=12, height=2)
        self.recButton.place(x = 100, y = 150)

    def record(self):
        Error.set("")
        if(self.name.get() != ""):
            if(not(recording.get())):
                recording.set(True)
                self.recButton['text']  ='Stop Recording'
                self.recButton['bg'] = 'red'
                file = open(self.name.get() + ".txt","a+")
                file.write("This is line %d\r\n" % (self.count))
                self.count += 1
                file.close()
                #save to text
            else:
                recording.set(False)
                self.recButton['text'] = 'Start Recording'
                self.recButton['bg'] = 'green'
        else:
            Error.set("Please enter a valid name")


class rightFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        self.config(bg="cyan", bd=2, relief="solid")   #Add BG color to frame
        
        tk.Label(self, text = "Select routine", font=("MS Serif", 10), bg="cyan", fg="black").place(x = 100, y = 25)

        self.vals = []
        self.cBox = ttk.Combobox(self, values = self.vals, postcommand = self.update)
        self.cBox.place(x = 100, y = 45)
        tk.Button(self, text = "Play", command = self.send, font=("MS Serif", 13), bg="green", fg="white", width=10, height=2).place(x = 100, y = 150)


    def update(self):
        self.cBox['values'] = self.vals

    def send(self):
        print(recording.get())

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)

        self.config(bg="cyan")   #Add BG color to window

        self.title('Miniproyecto de Microcontroladores')    #Window's title
        self.geometry('700x400')                            #Window's size
        self.resizable(False, False)                        #Not resizable cuz' not responsive designed

        leftFrame(self).place(x = 10, y = 10, height = 330, width = 340)
        rightFrame(self).place(x = 340, y = 10, height = 330, width = 340)

        tk.Label(self, text = "Record", font=("MS Serif", 12), bg="cyan", fg="black").place(x = 100, y = 0)
        tk.Label(self, text = "Play", font=("MS Serif", 12), bg="cyan", fg="black").place(x = 450, y = 0)

        global Error
        Error = tk.StringVar()
        Error.set("error")
        tk.Label(self, textvariable = Error, font=("MS Serif", 10), bg="cyan", fg="black", borderwidth = 5).place(x = 0, y = 350, height = 50, width = 300)
        
        self.mainloop()

App()
