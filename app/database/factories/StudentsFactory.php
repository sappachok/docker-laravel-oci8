<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Students;
use Faker\Generator as Faker;
use Illuminate\Support\Str;

/*
|--------------------------------------------------------------------------
| Model Factories
|--------------------------------------------------------------------------
|
| This directory should contain each of the model factory definitions for
| your application. Factories provide a convenient way to generate new
| model instances for testing / seeding your application's database.
|
*/

$factory->define(Students::class, function (Faker $faker) {
	static $year = 64; 
	static $order = 1; 
    return [
        'student_code' => $year.str_pad($order++,8,"0",STR_PAD_LEFT),
        'first_name' => $faker->firstName,
        'last_name' => $faker->lastName,
		'address' => $faker->address,
        'email' => $faker->unique()->safeEmail,
        'created_at' => now(),
        'updated_at' => now(),
    ];
});
