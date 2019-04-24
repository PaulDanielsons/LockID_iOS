# LockID_iOS
The swift component from LockID. 

<h5> Demo </h5>
<iframe width="560" height="315" src="https://www.youtube.com/embed/nnoEqrnZy-I" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<h1> What is LockID? </h1>
<p> LockID eliminates the deficiencies of traditional lock systems. With multifactor authentication, time-sensitive keys, and modern mobile biometric techniques, consumers know that lost or stolen keys will not compromise their security.  LockID makes managing physical security simple by integrating with pre-existing identity management systems and offers docker containers for its backend components. </p>

<h2> Components </h2>
LockID is broken up into 3 components which reference an Azure database.

<h3> Swift </h3>
<p> The iOS app is the user's interface </p> <br>
<p> The iOS app is designed to interact with the admin portal to understand the organizations settings and validate the user. This is executed using the backend APIs. The iOS app also interactes with the smart lock to exhange information and to modify the lock status (unlock/lock). </p>
 
<h3> Angular Web Portal </h3>
<p> The admin portal is the organization and adminstrators interface </p>
<p> Users are able to interact with the locks (name/permission..), and can perform orgnanizational and managerial tasks (add/remove/modify users..) </p>
<h3> UWP App </h3>
<p> Code for the digital lock </p>
<p> A repository to contain the current iteration of the UWP app to run on a Windows IoT Core device </p>






<footer> The full sourcecode is available at https://github.uc.edu/LockId <br> 2018-2019.</footer>
