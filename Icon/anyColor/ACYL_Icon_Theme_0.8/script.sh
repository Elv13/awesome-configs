first=`bash ./scalable/other/first`
if [ $first = true ]
then
	sed -i "s/ACYL_Icon_Theme_0.5\//ACYL_Icon_Theme_0.6\//g" ~/.fbpanel/default
	sed -i "s/ACYL_Icon_Theme_0.6\//ACYL_Icon_Theme_0.6.1\//g" ~/.fbpanel/default
	sed -i "s/ACYL_Icon_Theme_0.6.1\//ACYL_Icon_Theme_0.7\//g" ~/.fbpanel/default
	sed -i "s/ACYL_Icon_Theme_0.7\//ACYL_Icon_Theme_0.7.1\//g" ~/.fbpanel/default
	sed -i "s/ACYL_Icon_Theme_0.7.1\//ACYL_Icon_Theme_0.8\//g" ~/.fbpanel/default
	sed -i "s/true/false/" ./scalable/other/first
fi
cd scalable
cd scripts
bash ./script_menu
