# Glacier Watchdog
![G W D ](/Logo.png)
### Intro 
The current folders contains python utils to monitor the S3M simulation process. 
The main objective is to avoid potential pitfalls during simulation, in particular related to restart mismanagement. 
The script count_ice_thickness_pixels consider the "input" folder and checks the count of all valid pixels in between the contained images. 
It then produce an csv file with statistics reported.
If a -+ 20 % variation is detected an error is raised.
### Usage 
To launch the check and produce the relative ouput populate the input folder with the files to be checked.

