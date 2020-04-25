# Plotter
### Simple app that takes values from SerialPort and plots them in real time.

Data sent for plotting should be in the following format: `Label = value\n`. (**must include newline**)

To send multiple values, format should be: `Label1 = value1; Label2 = value2; Label3 = value3\n`.
The labels will be automatically be parsed and added as titles for each plot.

The terminal page (second image) features a console to see the raw received data and and send data to the other device.

![Img1](https://i.imgur.com/Lj94ojC.png)
![Img2](https://i.imgur.com/eNGl7ms.png)