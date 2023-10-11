# Nexus Repo Manager - Maven Bulk Upload Script

## Rationale

We needed to upload 3.5GB of third party Maven packages to Nexus Repo Manager (NXRM); somewhere in the region of 1600 POM and JAR files.

The upload script is based on [upload2nexus] (https://github.com/kschuemann/linux-scripting/blob/main/upload2nexus.sh) written by [KSchuemann](https://github.com/kschuemann).

## Notes

The find command was changed to the following:

~~~shell
find <DirName>/  -iname "*.pom" -printf "%h\n" > files; find <DirName>/ -iname "*.jar" -printf "%h\n" >> files; cat files | sort | uniq > artifacts
~~~

The original version of this command used uniq -u this did not return all folder paths in the artifacts file. I also left "files" in place - you can add the rm files back in as per the original procedure if you desire.

The following xpath query did not work for me:

~~~shell
<var>=$(echo $pompath | xargs xpath -e 'project/<varPath>/text()')
~~~

Where \<var> is one of groupId, artifactId or version. I installed xmllint and used the following:

~~~shell
<var>=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="<varPath>"]/text()' $pompath)
~~~

I also added the following tests:

Does the path only contain a POM file and no JAR file (typically a parent)?

~~~shell
if test -n "$pompath"  && test -z "$jarpath"
~~~

The run the following mvn command to upload the POM file (I had to put the command on one line):

~~~shell
mvn deploy:deploy-file -DgroupId=$groupId -DartifactId=$artifactId -Dversion=$version -Dpackaging=pom -Dfile=$pompath -DrepositoryId=nexus-ecm -Durl=http://${NEXUS_URL}/repository/maven-releases/ 
~~~

Does the folder contain a POM and a JAR file?

~~~shell
elif test -n "$pompath"  && test -n "$jarpath"
~~~

The run the following mvn command to upload the POM and JAR file to NXRM (again, the command is on one line):

~~~shell
mvn deploy:deploy-file -DpomFile=$pompath -Dfile=$jarpath -DgeneratePom=false -DrepositoryId=nexus-ecm -Durl=http://${NEXUS_URL}/repository/maven-releases/
~~~


