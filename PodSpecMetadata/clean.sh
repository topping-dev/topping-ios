#/bin/zsh

pod cache clean Topping --silent --all
pod cache clean ToppingIOSKotlinHelper --silent --all
rm -rf ../../topping-kotlin-sample/shared/build
rm -rf ../../topping-kotlin-sample/iosApp/Pods
rm -rf ../../topping-kotlin-sample-compose/shared/build
rm -rf ../../topping-kotlin-sample-compose/iosApp/Pods
rm -rf ../../topping-kotlin/toppingkotlin/build
#rm -rf /Users/edo/Documents/androidx-main/frameworks/support/.gradle
#rm -rf /Users/edo/Documents/androidx-main/out
#rm -rf /Users/edo/Documents/androidx-main/frameworks/out
#rm -rf /Users/edo/Documents/androidx-main/frameworks/support/buildSrc/.gradle
