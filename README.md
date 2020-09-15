# BrokenAds
Creates Flashable zip to update hosts file  in android devices with only Recovery access. DEVICE ROOT ACCESS IS NOT REQUIRED
 1.  It uses hosts records from StevenBlack/hosts avaialable at  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts .
      For other sources , update  $URLRAWBASE  variable.
 2.  Flashable zip contains 
        i. hosts file     
        ii. binary files (update-binary  & updater-script ) under META-INF/com/google/android
         
 3.  Output  file will be created  in the current directory. 
 4.  Previous builds  will be moved to  ./previous_builds

