#create a servers.csv file that has the list of server IP address or hostnames

import os
import csv
import time
from datetime import datetime
import smtplib



def sendEmail(m):
 	try:
 	 server = smtplib.SMTP('smtp.gmail.com', 587)
 	 server.ehlo()
 	 server.starttls()


 	 server.login("UNAME", "PASSWORD")

 	 x=""


 	 for i in m:
 	 	x=x+"\n"+str(i)

 	 msg = """From: Rohit Singh <From Email ID>
 	 To: WINCOM <To Email ID>
 	 Subject: Servers Not Working
 	 

 	 This is a test e-mail message.
 	 

 	 The following servers are down:
 	 

 	 """ + str(x) + """\n ok so get ready"""

 	 server.sendmail("From Email ID", "To Email ID", msg)
 	 server.quit()

 	except:
 	 print ('Something went wrong...')



servers=[]
m=[]

fin=0

f = open('servers.csv')
csv_f = csv.reader(f)
for row in csv_f:
  servers.append(row[0])

flag=0

now=datetime.now()
hr=now.hour

while True:
 m=[]
 now = datetime.now()
 print ('\n\n--------------------------------------\n Status for:     %s/%s/%s %s:%s:%s' % (now.month, now.day, now.year,now.hour, now.minute, now.second))
 for i in servers:
  hostname = i #example
  response = os.system("ping " + hostname + " | find \"Reply\" > nul")   #ping -n 1 %computer_name%  | find "Reply" > nul

  #and then check the response...
  if response == 0:
    print ('%s is up!' % hostname)
  else:
    print ('%s is down!' % hostname)
    m.append(i)
    flag=1
 
 if flag==1:
 	if now.hour!=hr and fin==1:
 		sendEmail(m)

 	if fin==0:
 		sendEmail(m)
 		fin=1


 time.sleep(1000)




 	
