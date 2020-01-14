#! /bin/bash

#PBS -l nodes=1:ppn=4,walltime=24:00:00
#PBS -m ea
#PBS -N download-rsei237gma.script

cd /N/dc2/scratch/ashm/rsei237gma 
# lftp -e 'pget -n 5 -c http://abt-rsei.s3.amazonaws.com/microdata2017/micro2017_2017.csv.gz; exit'
lftp -e 'pget -n 5 -c http://abt-rsei.s3.amazonaws.com/microdata2017/micro2017_2016.csv.gz; exit'

## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2017.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2016.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2015.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2014.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2013.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2012.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2011.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2010.csv.gz
## lftpget ftp://newftp.epa.gov/RSEI/Version237_RY2017/Disaggregated_Microdata/Micro2017_2009.csv.gz
