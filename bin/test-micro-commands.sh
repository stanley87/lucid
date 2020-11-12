#!/bin/sh

set -e

# Check if file or directory exists. Exit if it doesn't.
examine() {
    if [ ! -f $1 ] && [ ! -d $1 ]; then
        echo "\n-- ERROR -- $1 could not be found!\n"
        exit 1
    fi
}

# Lint a PHP file for syntax errors. Exit on error.
lint() {
    # echo "\n -- MISSING -- Lint file $1"
    RESULT=$(php -l $1)
    if [ ! $? -eq 0 ] ; then
        echo "$RESULT" && exit 1
    fi
}

examine "app/Providers"
examine "app/Providers/RouteServiceProvider.php"
examine "resources"
examine "resources/lang"
examine "resources/views"
examine "resources/views/welcome.blade.php"
lint "resources/views/welcome.blade.php"
examine "routes"
examine "routes/api.php"
examine "routes/web.php"
lint "routes/api.php"
lint "routes/web.php"
examine "tests"

# Controller
./vendor/bin/lucid make:controller trade
examine "app/Http/Controllers/TradeController.php"
lint "app/Http/Controllers/TradeController.php"

# Feature
./vendor/bin/lucid make:feature trade
examine "app/Features/TradeFeature.php"
lint "app/Features/TradeFeature.php"
examine "tests/Features/TradeFeatureTest.php"
lint "tests/Features/TradeFeatureTest.php"

# Job
./vendor/bin/lucid make:job submitTradeRequest shipping
examine "app/Domains/Shipping/Jobs/SubmitTradeRequestJob.php"
lint "app/Domains/Shipping/Jobs/SubmitTradeRequestJob.php"
examine "app/Domains/Shipping/Tests/Jobs/SubmitTradeRequestJobTest.php"
lint "app/Domains/Shipping/Tests/Jobs/SubmitTradeRequestJobTest.php"

./vendor/bin/lucid make:job sail boat --queue
examine "app/Domains/Boat/Jobs/SailJob.php"
lint "app/Domains/Boat/Jobs/SailJob.php"
examine "app/Domains/Boat/Tests/Jobs/SailJobTest.php"
lint "app/Domains/Boat/Tests/Jobs/SailJobTest.php"

# Model
./vendor/bin/lucid make:model bridge
examine "app/Data/Bridge.php"
lint "app/Data/Bridge.php"

# Operation
./vendor/bin/lucid make:operation spin
examine "app/Operations/SpinOperation.php"
lint "app/Operations/SpinOperation.php"
examine "tests/Operations/SpinOperationTest.php"
lint "tests/Operations/SpinOperationTest.php"

./vendor/bin/lucid make:operation twist --queue
examine "app/Operations/TwistOperation.php"
lint "app/Operations/TwistOperation.php"
examine "tests/Operations/TwistOperationTest.php"
lint "tests/Operations/TwistOperationTest.php"

./vendor/bin/lucid make:policy fly
examine "app/Policies/FlyPolicy.php"
lint "app/Policies/FlyPolicy.php"

# Ensure nothing is breaking
./vendor/bin/lucid list:features
./vendor/bin/lucid list:services

# Run PHPUnit tests
if [ ! -f ".env" ]; then
    echo 'APP_KEY=' > .env
    php artisan key:generate
fi

./vendor/bin/phpunit

./vendor/bin/lucid delete:feature trade
./vendor/bin/lucid delete:job submitTradeRequest shipping
./vendor/bin/lucid delete:job sail boat
./vendor/bin/lucid delete:model bridge
./vendor/bin/lucid delete:operation spin
./vendor/bin/lucid delete:operation twist
./vendor/bin/lucid delete:policy fly
rm app/Http/Controllers/TradeController.php


echo "\nPASSED!\n"

exit 0
