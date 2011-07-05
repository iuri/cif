ls
mv openacs-5.6.0.tgz\?revision_id\=3405577 openacs-5.6.0.tgz
tar -xzvf openacs-5.6.0.tgz 
ls
rm openacs-5.6.0.tgz 
mv openacs-5.6.0/* .
ls -a openacs-5.6.0/
rm -rf openacs-5.6.0/
exit
ls
git init
git config --global user.name "Iuri Sampaio"
git config --global user.email iuri.sampaio@iurix.com
ls
git add ./
git commit -m 'first commit'
ls
git status
git remote add origin git@github.com:iuri/cif.git
git push origin master
git push origin master
git remote add origin git@github.com:iuri/cif.git
git push origin master
exit
pwd
wget http://openacs.org/projects/openacs/download/download/openacs-5.6.0.tgz?revision_id=3405577
ssh-keygen -t rsa
vi .ssh/id_rsa.pub 
git status
git push origin master
exit
git pull origin master
exit
