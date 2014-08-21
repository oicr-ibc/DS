#!/bin/bash
# copy files to remote workers 
scp -P 2222 -i ~/.vagrant.d/insecure_private_key  /home/iborozan/work/datashield/DataShield_no_Opal/DS/Rscripts/dc1.R vagrant@localhost:/home/vagrant/
scp -P 2200 -i ~/.vagrant.d/insecure_private_key  /home/iborozan/work/datashield/DataShield_no_Opal/DS/Rscripts/dc2.R vagrant@localhost:/home/vagrant/
scp -P 2201 -i ~/.vagrant.d/insecure_private_key  /home/iborozan/work/datashield/DataShield_no_Opal/DS/Rscripts/dc3.R vagrant@localhost:/home/vagrant/
# execute the scripts 
vagrant ssh worker-1 -c "R CMD BATCH /home/vagrant/dc1.R"
vagrant ssh worker-2 -c "R CMD BATCH /home/vagrant/dc2.R"
vagrant ssh worker-3 -c "R CMD BATCH /home/vagrant/dc3.R"
# for ports see .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory 
# get individual data from the workers for the meta-analysis on the AC 
scp -P 2222 -i ~/.vagrant.d/insecure_private_key  vagrant@localhost:/home/vagrant/mdf1.RData /home/iborozan/work/datashield/DataShield_no_Opal/
scp -P 2200 -i ~/.vagrant.d/insecure_private_key  vagrant@localhost:/home/vagrant/mdf2.RData /home/iborozan/work/datashield/DataShield_no_Opal/
scp -P 2201 -i ~/.vagrant.d/insecure_private_key  vagrant@localhost:/home/vagrant/mdf3.RData /home/iborozan/work/datashield/DataShield_no_Opal/

