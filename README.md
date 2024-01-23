# PowerCSR
**A GUI form built in Powershell to efficiently generate a CSR and Private Key file using OpenSSL for quick and easy cert generation**

<a href='https://ko-fi.com/Z8Z6E0CY0' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Use this tool to quickly do CSR requests for SSL certificates using Powershell on Windows.

# Prequisites

1. Make sure you first have OpenSSL installed and your environmental variables set so that you can get to open ssl from a terminal for this.

2. Open the .ps1 file in the directory that you want to generate the files.

![01 Main Menu](https://github.com/reprodev/PowerCSR/assets/8764255/01f61ccd-8b81-4be4-a462-fba2b5bfa50f)

3. Go ahead and enter some details and a password if you want to with in built error checking to make sure that they match or leave empty for no password on the private key which can be useful for embedded devices such as firewalls.

![02 Some Details](https://github.com/reprodev/PowerCSR/assets/8764255/87985765-f898-4782-9773-6282e5091c01)

4. The CSR and Private Key will be generated and a success message if everything went well.

![03 Generated CSR Success](https://github.com/reprodev/PowerCSR/assets/8764255/c91f9633-4cb0-422f-a836-0a053a3246d0)

5. You'll find your files in the directory that you have run this from.

![04 Generated Files](https://github.com/reprodev/PowerCSR/assets/8764255/fc71453d-5b4b-45fc-8cb6-638f523fce37)

6. We can double check that this is the correct information by going to an online CSR Decoder like this and paste in the CSR file text to check

https://www.sslshopper.com/csr-decoder.html

![05 CSR Decoder](https://github.com/reprodev/PowerCSR/assets/8764255/716d26e9-5bf4-489e-aa26-f67cf5a12abf)

7. By default the encryption is set to 2048 bits and allows you to generate again without having to retype into the command line OpenSSL.

8. Enjoy your freshly made CSR and Private Key without the frustration

# Finally!

Please go ahead and follow me for more and feel free to comment on if this works for you, if you've found a way to make this process better or if there is anything in here that needs to be amended to make it flow better. I'd love to hear from anyone that has given this a try

<a href='https://ko-fi.com/Z8Z6E0CY0' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Yours technically,
ReproDev

# Still To Do: Work on the design of the UI - Last Edit 23/01/2024


