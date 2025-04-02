Getting Started
###############


MAPPINGS is written in Fortran and does not require anything but a moderately modern version 
of fortran to install.  

The latest versions of MAPPINGS and the primary site for obtaining the source code 
and associated data files are listed here `<https://mappings.anu.edu.au/code/>`_

Most of the recent develpment has been carried out using gfortran. 
Most of the developers are currently using MACOs or linux (ubnuntu), and the standard 
Makefile is intended to run on either system.  We provide some Makefiles for some other 
versions of Fortran, as well but these are less well tested with recent versions of MAPPINGS
and if anyone encounters prablems wit installation, please describe your problem on the issues
page of the repository.


-------------
Installation
-------------

MAPPINGS and the various routines associated with it are in a self-contained directory structure, which needs
to be retreived from BitBucket.

.. code :: bash

    $git clone git@bitbucket.org:RalphSutherland/mappings.git


Once you have downloaded the repository, you need got to the src directory within the distribuiton

.. code :: bash

    $cd mappaings/src


and then if you have gfortan on your machine you should be able to compile MAPPINGS with the command

.. code :: bash

    $make build


It should be obvious from what is printed out to the terminal whether the compilaton has been successful

The existing make file should work on MacOS or on most linux distributions.  If you encounter problems, there 
are other makefiles that may be more appropriate for your system in  altmakefiles directory.

The make build compiles executables and places them in the mappings/bin directory.


At this point you have two options:

* Set up enviroment variables to point to the local installation of MAPPINGS on your computer.  This is the
  preferred option for most users if you are the sole user, but it requires you to add several lines to your profile to
  access MAPPINGS properly.  It has the advantabe that you can easily determine what executable versons of MAPPINGS are
  available.

* Installing the code in a central location for use by you and others on a machine.  This is the apppropriate option 
  for inatallation for a group of users, where one person is responsible for the MAPPINGS coed, but there are a number
  of users who should be using the identical version of the code.


-------------
Single  Users
-------------

For personal users, the only thing that needs to be done after building MAPPINGS as described above is to add the 
following lines to one of your profile files (for bash, either .bash_profile or .bashrc, whichever you prefer).    

The commands for bash and it variants are:

.. code :: bash

    export MAPPINGS=path/to/mappings/
    PATH=$PATH:$mappings/bin/
    export PATH


where  MAPPINGS points to the top level directory for the mappins installation.

for csh, tcsh and other similar shells the commmnad sould be 

.. code :: csh

   setenv MAPPINGS path/to/MAPPINGS
   PATH=$PATH:$mappings/bin/
   export PATH

Defining the $MAPPINGS variable is require because is required to locate the data files.

Aside: If you are installing for yourself a version of MAPPINGS on a machine where there is also a system installation, 
you may need to change to order of the PATH search, using by replacing the PATH command above by

.. code :: bash

   $PATH-$mappings/bin/:$PATH

-------------
Multiple Users
-------------

For multiple users, one does not need to add anything to the profile files.  Instead, the person resposible 
for installing MAPPINGS should the following command from within the src directory

.. code :: terminal

   $ make install


or depending on the user's privileges

.. code :: terminal

   $ sudo make install

This will install MAPPINGS in /usr/local

Aside: There are also options to install in /opt/local if that is preferred.  To see these options, we refer the user to the
Makefile itself.

-------------
Updating MAPPINGS
-------------

Assuming you have downloaded MAPPINGS as a git archive, updating the stable version of MAPPINGS is straightforward.  Simple 
go to the MAPPINGS directory an issue the follwoing command, and then repeat the build process descibed above.

.. code :: bash

    $ git pull origin public

Aside: There will be other branches on the BitBucket site, but the public branch is the one that is relatively stable, and should
be the branch that most researchers use.  We may encourage some users to test other branches, but all of these branches are experimental
and subject to rapid change.

-------------
Removing MAPPINGS
-------------

To remove MAPPINGS from your system, personal users need only to delete the MAPPINGS directory (and if they wish the lines 
added to the setup files (.bash_profile or .bashrc for bash users.

To remove MAPPINGS for installations for multiple users, the following command should be issued from the mapings/src dirctor:

.. code :: terminal

   $ [sudo] make uninstall

After this the MAPPINGS directory itself can be removed.










