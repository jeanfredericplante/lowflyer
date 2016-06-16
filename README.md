# Low Flyer: an open zipper detector
Finally, science made useful!
Low Flyer is an open zipper detector app. It is based on the magnetometer and accelerometer data of your iphone.
Based on inductance variation from your zipper, and detection of walking pattern based on the accelerometer, the app (intent) is to differentiate based on the amplitude of inductance variation an opened zipper from a closed zipper - and warn you with a soothing Siri voice that your zipper is opened. Timeliness of the warning is an in app purchase.

# Analysis
Attached are the matlab scripts I used to analyze whether there was a signal. I clearly see from the magnetic signal the walking frequency. There is a secondary harmonic that is higher when the zipper is opened, which looks this was the expected pattern as the zipper shape variability is greater. 
Here is what the elusive zipper signal looks like. To run the scripts, you might use octave online.

![alt tag](https://cloud.githubusercontent.com/assets/552539/13768359/6d8f9d02-ea32-11e5-883d-625e1db6ffb7.png)
