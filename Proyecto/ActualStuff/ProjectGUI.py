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
        data.reset_input_buffer()
        break
    except:
        print("Unable to open port")                    #Error if port error/timeout


bgColor = "cyan"

def refreshSerial(first):
    result = None   #Receiving data as none
    
    #data.reset_input_buffer()
    
    while(result is None):  #While there's nothing on the serial buffer
##        if(not(progressRecord.winfo_ismapped()) and not(data.in_waiting)):  #If processing progress bar not on window and no data waiting
##            return(0)
        result = data.readline(1)   #Read a byte from buffer
    result = ord(result)    #Convert incoming byte to int
#TEST
    return(result)  #Return int

def parametrization(list1, list2):

    list3 = [list2[0] - list1[0], list2[1] - list1[1], list2[2] - list1[2], list2[3] - list1[3]]
    returningList = []
##    for x in range(25, 1, -1):
##        returningList.append([ round(list3[0]/x + list1[0], 0), round(list3[1]/x + list1[1], 0) , round(list3[2]/x + list1[2], 0), round(list3[3]/x + list1[3], 0) ])
##
##    for y in range(1, 25, 1):
##        returningList.append([ round(list3[0]*(1-1/(2*y)) + list1[0], 0), round(list3[1]*(1-1/(2*y)) + list1[1], 0) , round(list3[2]*(1-1/(2*y)) + list1[2], 0), round(list3[3]*(1-1/(2*y)) + list1[3], 0) ])
####
##    for x in range(18):
##        returningList.pop(0)
    counter = 5
    for x in range(1, counter - 1, 1):
        returningList.append([ round(list3[0]*(x/counter) + list1[0], 0), round(list3[1]*(x/counter) + list1[1], 0) , round(list3[2]*(x/counter) + list1[2], 0), round(list3[3]*(x/counter) + list1[3], 0) ])

    return(returningList)

class refreshFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        #Init of var for missing bytes in buffer
        global amountMissing
        amountMissing = tk.IntVar()
        amountMissing.set(0)

##        self.count = 0

        #Var for receiving the initial OK from PIC while recording (1)
        global first
        first = tk.BooleanVar()
        first.set(True)

        #Timer interval (ms)
        self.TimerInterval = 1
        #Calling timer function
        self.refresh()
        
        
    def refresh(self):
        
        if(recording.get() and initRecord.get()):    #If recording
##            if(progressRecord.winfo_ismapped()):    #If processing progressbar is displayed
##                progressRecord.step(100/amountMissing.get())   #make a step each byte received
##                if(not(data.in_waiting)):   #When no data left
##                    progressRecord.place_forget()   #Remove processing progress bar
                    ######add processing message

##            print(self.count)
##            self.count += 1
##            print("ProgressRecord: " + str(not(progressRecord.winfo_ismapped())))
##            print("Buffer: " + str(not(data.in_waiting)))
##            print("ProgressBar: " + str(progressbar.winfo_ismapped()))
##            print("Recording: "+ str(recording.get()))

            result1 = None
            while(1):
                result1 = None
                while(result1 is None):
                    result1 = data.readline(1)
                result1 = ord(result1)
                if(result1 == 1):
                    break

            for x in range(4):
                #Save incoming data to internal db
                file = open(rName.get() + ".txt","a")
                in_num = refreshSerial(first.get())
                if(in_num != 0):    #If it's not the first byte
                    
                    file.write("%d\n" % (in_num))
                print("Received " + str(in_num))
                if(first.get()):
                    first.set(False)    #Set var to false
                file.close()

            data.reset_input_buffer()

        # Now repeat call
        self.after(self.TimerInterval,self.refresh)

class leftFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        #Recording feedback image
        self.path = "Rec.png"    #Define image path
        self.background_image=tk.PhotoImage(file = self.path)   #Create variable with image
        self.lbl = tk.Label(self, image=self.background_image, width=50, height=10, bg=bgColor) #Initialize label with image

#TEST
        global initRecord
        initRecord = tk.BooleanVar()
        initRecord.set(False)

        #Progress bar for processing the recording
        global progressRecord
        progressRecord = ttk.Progressbar(self, maximum=100)
        

        global rName         #Name of current Routine
        rName = tk.StringVar()
        rName.set("")

        #Global var to determine if currently recording
        global recording
        recording = tk.BooleanVar()
        recording.set(False)

        global processMessage
        processMessage = tk.StringVar()
        processMessage.set("")
        tk.Label(self, textvariable = processMessage, font=("MS Serif", 10), bg=bgColor, fg="black").place(x = 72, y = 92)
        

#TEST
        self.count = tk.IntVar()
        self.count.set(1)

        self.config(bg=bgColor, bd=2, relief="solid")   #Add aesthetics to frame

        #Label above text input
        tk.Label(self, text = "Routine name", font=("MS Serif", 10), bg=bgColor, fg="black").place(x = 40, y = 25)
        
        self.name = tk.StringVar()  #Var for the inputbox
        tk.Entry(self, textvariable = self.name).place(x = 40, y = 45)  #inputbox creation and placement

        global recButton        #Recording button
        recButton = tk.Button(self, text = "Start Recording", command = self.record, font=("MS Serif", 13), bg="green", fg="white", width=12, height=2) #init
        recButton.place(x = 45, y = 150)    #placement

    def record(self):
        Error.set("")   #Reset error's message
        if(self.name.get() != ""):      #If there's a name on inputbox
            if(not(recording.get())):   #If recording
                amountMissing.set(1)    #amount missing on serial set to 1
                recording.set(True)     #Set that recording
                button.config(state = "disabled", bg = "grey64", text = "Recording")    #Disable the play button 
                recButton['text']  ='Stop Recording'       #Change button's properties
                recButton['bg'] = 'red'
                rName.set(self.name.get())            #Change var's value
                file = open(rName.get() + ".txt","w+")   #Open and clear file
                file.write("")
                file.close()

                #send 1 to PIC
                self.sending = 1
                self.sending = chr(self.sending)
            
                data.write(bytes(self.sending.encode()))
                
                #Wait till receiving data
                while(not(data.in_waiting)):
                    print("waiting")

#TEST
                initRecord.set(True)
                print("Out first click")

                #Timer interval (ms)
                self.TimerInterval = 500
                #Calling timer function
                self.receive()
            else:
                print(data.in_waiting)
                initRecord.set(False)
                #send 0 to PIC
                self.sending = 0
                self.sending = chr(self.sending)
                
                data.write(bytes(self.sending.encode()))

                #Placement of processing progress bar 
                #progressRecord.place(x = 7, y = 120, width = 215)
                

                amountMissing.set(data.in_waiting)
                
        else:   #If no name entered
            Error.set("Please, enter a valid name")

    def receive(self):
###############################################################################
        
        if(recording.get()):    #if recording
            if( not(initRecord.get())): #processing progress bar is not placed and no data in buffer
                first.set(True)
                amountMissing.set(0)
                button.config(state = "active", bg = "green", text = "Play")    #Enable play button
                self.lbl.place_forget()     #Reset the recording feedback image
                    
                recording.set(False)        #Set that not recording
                recButton['text'] = 'Start Recording'  #Change button's properties
                recButton['bg'] = 'green'

            
            if(len(self.lbl.place_info())):#If image on window
                self.lbl.place_forget()
            else:   #If image not on window
                self.lbl.place(x = 192, y = 0, width=40, height=20)

        #If processing, toggle message
        if(progressRecord.winfo_ismapped()):
            processMessage.set("Processing")
        else:
            processMessage.set("")

        # Now repeat call
        self.after(self.TimerInterval,self.receive)


class rightFrame(tk.Frame):
    def __init__(self,master,*args,**kwargs):
        tk.Frame.__init__(self,master,*args,**kwargs)

        #Interval at which data is sent to PIC
        self.TimerInterval = 1

        #Global var for instruccions to send
        global instructions
        instructions = []

        #Globarl var for the initial amount of intructions
        global amount
        amount = tk.IntVar()
        amount.set(0)

        self.config(bg=bgColor, bd=2, relief="solid")   #Add BG color to frame
        
        tk.Label(self, text = "Select routine", font=("MS Serif", 10), bg=bgColor, fg="black").place(x = 40, y = 25)    #creation and placemento of label

        self.vals  = [""]       #Var for routines on folder
        self.cBox = ttk.Combobox(self, values = self.vals, postcommand = self.update, state="readonly") #Combobox to select routine
        self.cBox.place(x = 40, y = 45) #placement of combobox

        #init of progress bar
        global progressbar
        progressbar = ttk.Progressbar(self, maximum=100)
        
        #init an placement of play button
        global button
        button = tk.Button(self, text = "Play", command = self.play, font=("MS Serif", 13), bg="green", fg="white", width=10, height=2)
        button.place(x = 60, y = 150)

        self.refresh()


    def update(self):   #when dropdown menu is pressed
        self.vals = [x for x in os.listdir() if 'txt' in x] #Select all archive names in which 'txt' appears
        self.cBox['values'] = self.vals     #set it to combobox's values

    def play(self):     #When play button is pressed
        Error.set("")   #Clear error message
        if(self.cBox.get() == ""):  #If no routine is selected
            Error.set("Seleccione una rutina a ejecutar")
        else:
            button.config(state = "disabled", bg = "grey64", text = "Playing")  #Desables itself
            recButton.config(state = "disabled", bg = "grey64", text = "Playing")   #desable the recording button
            progressbar.place(x = 10, y = 100, width = 215)                     #Places progress bar
            file = open(self.cBox.get(),"r")                                    #Opens an reads the whole file
            print(self.cBox.get())
            content = file.read()
            file.close()

            amount.set(content.count('\n'))         #Count total amount of initial instructions

            #send 2 to PIC
            self.sending = 2
            self.sending = chr(self.sending)
            print("Sending 2")
            print(self.sending)
            print(type(self.sending))
            print("2 sent")
        
            data.write(bytes(self.sending.encode()))
            
            while(content.count('\n')):             #Place all values into an list
                instructions.append(int(content[:content.find('\n')]))
                content = content[content.find('\n') + 1:]

    def refresh(self):

##        if(progressbar.winfo_ismapped()):
##            if(len(instructions)):  #If there are still instructions
##
####                #Select first value in instructions
####                self.sending = int(instructions.pop(0))
####                self.sending = chr(self.sending)    #Convert to char
####
##                progressbar.step(400/amount.get())  #Make a step on progressbar
####            
####                data.write(bytes(self.sending.encode()))    #Send instruction
##
##                p1 = []
##                p2 = []
##                for x in range(4):
##                    p1.append(instructions.pop(0))
##
##                if(len(instructions)):
##                    for x in range(4):
##                        p2.append(instructions[x])
##
##                    inst = parametrization(p1, p2)
##                    
##                    if(len(p1)):
##                        for y in range(4):
##                            self.sending = int(p1.pop(0))
##                            self.sending = chr(self.sending)    #Convert to char
##                        
##                            data.write(bytes(self.sending.encode()))    #Send instruction
##
##                            print(bytes(self.sending.encode()))
##                        
##                    for x in range(len(inst)):
##                        subInst = inst.pop(0)
##                        for y in range(4):
##                            self.sending = int(subInst.pop(0))
##                            self.sending = chr(self.sending)    #Convert to char
##                        
##                            data.write(bytes(self.sending.encode()))    #Send instruction
##
##                            print(bytes(self.sending.encode()))
##
##                        if(len(p2)):
##
##                            for y in range(4):
##                                self.sending = int(p2.pop(0))
##                                self.sending = chr(self.sending)    #Convert to char
##                            
##                                data.write(bytes(self.sending.encode()))    #Send instruction
##
##                                print(bytes(self.sending.encode()))
##                    
##
##                print(len(instructions))
##                
##                if not(len(instructions)):  #If there are no instructions left
##                    progressbar.place_forget()  #Removes the progress bar
##                    button.config(state = "active", bg = "green", text = "Play")    #Reenables play button
##                    recButton.config(state = "active", bg = "green", text = "Start Recording")  #Reenables recording button
##
##                    self.sending = 0
##                    self.sending = chr(self.sending)
##
##                    x = 1
##                    while(x <= 5):  #Sends 0 to PIC 4 times to finish the routine
##                        data.write(bytes(self.sending.encode()))
##                        x += 1
        
        # Now repeat call
        self.after(self.TimerInterval,self.refresh)

class App(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)

        self.config(bg=bgColor)   #Add BG color to window

        self.title('Proyecto de Microcontroladores')    #Window's title
        self.geometry('700x400')                            #Window's size
        self.resizable(False, False)                        #Not resizable cuz' not responsive designed

        #Title labels
        tk.Label(self, text = "Proyecto (Brazo)", font=("MS Serif", 13), bg=bgColor).place(x = 180, y = 15)
        tk.Label(self, text = "Por: Alejandro Recancoj y José Ramírez", font=("MS Serif", 9), bg=bgColor).place(x = 155, y = 45)

        # Frame placement
        leftFrame(self).place(x = 10, y = 100, height = 230, width = 240)
        rightFrame(self).place(x = 240, y = 100, height = 230, width = 240)
        refreshFrame(self).place(x = 0, y = 0)

        #Subtitle label
        tk.Label(self, text = "Record", font=("MS Serif", 12), bg=bgColor, fg="black").place(x = 50, y = 85)
        tk.Label(self, text = "Play", font=("MS Serif", 12), bg=bgColor, fg="black").place(x = 275, y = 85)
        
        #Globar var to send error message
        global Error
        Error = tk.StringVar()
        tk.Label(self, textvariable = Error, font=("MS Serif", 10), bg=bgColor, fg="black", borderwidth = 5).place(x = 0, y = 350, height = 50, width = 300)
        
        while True:

        
            if(recording.get() and initRecord.get()):    #If recording
    ##            if(progressRecord.winfo_ismapped()):    #If processing progressbar is displayed
    ##                progressRecord.step(100/amountMissing.get())   #make a step each byte received
    ##                if(not(data.in_waiting)):   #When no data left
    ##                    progressRecord.place_forget()   #Remove processing progress bar
                        ######add processing message

    ##            print(self.count)
    ##            self.count += 1
    ##            print("ProgressRecord: " + str(not(progressRecord.winfo_ismapped())))
    ##            print("Buffer: " + str(not(data.in_waiting)))
    ##            print("ProgressBar: " + str(progressbar.winfo_ismapped()))
    ##            print("Recording: "+ str(recording.get()))

                result1 = None
                while(1):
                    result1 = None
                    while(result1 is None):
                        result1 = data.readline(1)
                    result1 = ord(result1)
                    if(result1 == 1):
                        break

                for x in range(4):
                    #Save incoming data to internal db
                    file = open(rName.get() + ".txt","a")
                    in_num = refreshSerial(first.get())
                    if(in_num != 0):    #If it's not the first byte
                        
                        file.write("%d\n" % (in_num))
                    print("Received " + str(in_num))
                    if(first.get()):
                        first.set(False)    #Set var to false
                    file.close()

            #data.reset_input_buffer()

            
            if(progressbar.winfo_ismapped()):
                if(len(instructions)):  #If there are still instructions
                    time.sleep(0.001)

    ##                #Select first value in instructions
##                    self.sending = int(instructions.pop(0))
##                    self.sending = chr(self.sending)    #Convert to char
    ##
                    progressbar.step(400/amount.get())  #Make a step on progressbar
    ##            
##                    data.write(bytes(self.sending.encode()))    #Send instruction

                    p1 = []
                    p2 = []
                    for x in range(4):
                        p1.append(instructions.pop(0))

                    if(len(instructions)):
                        for x in range(4):
                            p2.append(instructions[x])

                        inst = parametrization(p1, p2)
                        
                        if(len(p1)):
                            for y in range(4):
                                self.sending = int(p1.pop(0))
                                self.sending = chr(self.sending)    #Convert to char
                            
                                data.write(bytes(self.sending.encode()))    #Send instruction

                                print(bytes(self.sending.encode()))
                            
                        for x in range(len(inst)):
                            subInst = inst.pop(0)
                            for y in range(4):
                                self.sending = int(subInst.pop(0))
                                self.sending = chr(self.sending)    #Convert to char
                            
                                data.write(bytes(self.sending.encode()))    #Send instruction

                                print(bytes(self.sending.encode()))

                            if(len(p2)):

                                for y in range(4):
                                    self.sending = int(p2.pop(0))
                                    self.sending = chr(self.sending)    #Convert to char
                                
                                    data.write(bytes(self.sending.encode()))    #Send instruction

                                    print(bytes(self.sending.encode()))
                        

                    print(len(instructions))
                    
                    if not(len(instructions)):  #If there are no instructions left
                        progressbar.place_forget()  #Removes the progress bar
                        button.config(state = "active", bg = "green", text = "Play")    #Reenables play button
                        recButton.config(state = "active", bg = "green", text = "Start Recording")  #Reenables recording button

                        self.sending = 0
                        self.sending = chr(self.sending)

                        x = 1
                        while(x <= 5):  #Sends 0 to PIC 4 times to finish the routine
                            data.write(bytes(self.sending.encode()))
                            x += 1
            self.update()

App()
