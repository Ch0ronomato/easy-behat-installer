# This script will download and install behat easy.

# get the url from the user
echo "Please enter the site url: "
read site

# fill the json file
touch composer.json
echo '{
    "require": {
        "behat/behat": "2.4.*@stable",
        "behat/mink": "1.4.*@stable",
        "behat/mink-extension": "*",
        "behat/mink-goutte-driver": "*",
        "behat/mink-selenium2-driver": "*"
    },
    "minimum-stability": "dev",
    "config": {
        "bin-dir": "bin/"
    }
}
' >> composer.json;

# install composer
curl http://getcomposer.org/installer | php
php composer.phar install

# init behat
bin/behat --init

#fill in the behat.yml
touch behat.yml
echo "# behat.yml
default:
  extensions:
    Behat\MinkExtension\Extension:
      goutte: ~
      selenium2: ~
      base_url: $site
" >> behat.yml

# enforce using the mink context
cd features/bootstrap
line_nums=$(wc -l < FeatureContext.php)
echo $line_nums;

touch temp_bootstrap
head -n 1 FeatureContext.php >> temp_bootstrap;
echo "use Behat\MinkExtension\Context\MinkContext;" >> temp_bootstrap;

# offset for first line, our appended line, the php declaration, and the extra white space.
count=$(expr $line_nums - 2)
tail -n $count FeatureContext.php >> temp_bootstrap;

sed "s/extends BehatContext/extends MinkContext/" temp_bootstrap > FeatureContext.php
rm temp_bootstrap

cd ../../
bin/behat -dl
