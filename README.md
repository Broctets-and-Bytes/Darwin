# Darwin
---Darwin-Collector.sh 
#This script is designed to be run against a mounted image, live system, or device in target disk mode. The script automates the collection
  of key files for MacOS investigations. The culled data set is only a fraction of the total volume. This dataset excludes specific user data
   such as pictures, videos, text documents, etc. It also excludes application data required to execute a program. This is purely a tool to 
   harvest the information required to start an investigation of the machine and actions taken on the machine. Industry tools like Blacklight
   and EnCase have canned processes that takes hours if not days and return only some of the information in these files. While they can be processed
   utilizing those tools, this data is best reviewed with intention. A folder structure is used to help guide that selective process. While the
   script copies timestamps and xattributes as best as possible, it is always wise to validate subjective findings against any forensically acquired copy
    of the data. 
