#!/bin/bash
# You can add variables here or just hard-code the URL in the -Durl parameter
NEXUS_USERNAME=""
NEXUS_PASSWORD=""
NEXUS_URL=""

# Generate the artifacts file using the following (where DirName is the name of the directory hosting your maven packages):
# find <DirName>/  -iname "*.pom" -printf "%h\n" > files; find <DirName>/ -iname "*.jar" -printf "%h\n" >> files; cat files | sort | uniq > artifacts
# I had to use xmlint (RHEL = yum install xmlint - change this to suit your distro)
cat artifacts | while read i; do

     pompath=$(find $i -name *.pom)
     jarpath=$(find $i -name *.jar)
     # If the folder contains a pom file only then....
     if test -n "$pompath"  && test -z "$jarpath"
     then
     
          groupId=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="groupId"]/text()' $pompath)
          artifactId=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' $pompath)
          version=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' $pompath)

          # Some POM folders contain POM files only but they are not parents 
          if test -z "$groupId"
          then
               echo "project-groupId is empty - using parent/groupId"
               groupId=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="groupId"]/text()' $pompath)
               version=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="version"]/text()' $pompath)

          fi
               #echo $jarpath
               #echo $pompath
               mvn deploy:deploy-file -DgroupId=$groupId -DartifactId=$artifactId -Dversion=$version -Dpackaging=pom -Dfile=$pompath -DrepositoryId=nexus-ecm -Durl=http://${NEXUS_URL}/repository/maven-releases/ 
     # If the folder contains a pom and a jar file then....
          elif test -n "$pompath"  && test -n "$jarpath"
          then
               #echo $jarpath
               #echo $pompath
               mvn deploy:deploy-file -DpomFile=$pompath -Dfile=$jarpath -DgeneratePom=false -DrepositoryId=nexus-ecm -Durl=http://${NEXUS_URL}/repository/maven-releases/
          fi
done 
echo 'done uploading artifacts'
