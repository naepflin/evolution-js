'use strict';

angular.module('myApp.view1', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {
    templateUrl: 'view1/view1.html',
    controller: 'View1Ctrl'
  });
}])

.controller('View1Ctrl', ['$scope', '$window', function($scope, $window) {

// init

	$scope.animals = [];
	var fields = [];
	$scope.processCounter = 0;
	$scope.processRunning = false;

	// generate fields
	var nbFieldsX = 10;
	var nbFieldsY = 10;


	for (var i = 0; i < nbFieldsX; i++) {
		var row = [];
		for (var j = 0; j < nbFieldsY; j++) {
			if (i == 0 || i == nbFieldsX || j == 0 || j == nbFieldsY) {
				row.push(new field(true));
			}
			else {
				row.push(new field(false));
			}
		}
		fields.push(row);
	}

// end init



	$scope.start = function() {

		$scope.processRunning = true;

		while ($scope.processRunning)
		{
			if ($scope.animals.length < $scope.stopAt) {
				$scope.stop();
				$window.alert("Only " + $scope.stopAt + " animals left.");
			}

			if ($scope.animals.length < 1) {
				$scope.stop();
				$window.alert("All animals died.");
			}

			// all animals move
			for (var i = 0; i < $scope.animals.length; i++) {
				$scope.animals[i].move();
				// include population statistics here
			}

			// all fields grow
			for (var i = 0; i < nbFieldsX; i++) {
				var row = fields[i];
				for (var j = 0; j < nbFieldsY; j++) {
					row[j].grow();
				}
			}
			$scope.processCounter++;
		}
	}

	$scope.stop = function() {
		$scope.processRunning = false;
	}

	$scope.createAnimals = function() {
		for (var i = 0; i < $scope.nbCreateAnimals; i++) {
			$scope.animals.push(new animal(null, null));
		}
	}

	$scope.resetProcessCounter = function() {
		$scope.processCounter = 0;
	}

	$scope.killAllAnimals = function() {
		$scope.animals.forEach(function(animal) {
			animal.die();
		});
	}




	// class "field"

	function field(onBorder) {

		//fieldType = 1: grows food 1
		//fieldType = 2: grows food 2
		//fieldType = 3: on border

		if (onBorder) {
			this.fieldType = 3;
		}
		else {
			this.fieldType = Math.floor(Math.random() * 2) + 1;
		}

		this.animalId = null;
		this.pasture = 1000;


		this.grow = function() {
			this.pasture += 500;
		};

		this.use = function() {
			if (this.pasture > 0) {
				this.pasture -= 100;
				return true;
			}
			return false;
		};

		this.newAnimal = function (animalId) {
			this.animalId = animalId;
		};
	}

	// class "animal"

	function animal(father, mother) {

		// state
		this.energy;
		this.age;
		this.positionX;
		this.positionY;
		this.alreadyMoved;

		// form
		this.sex;
		this.food1Specialization;
		this.food2Specialization;

		// behavior
		this.food1Preference;
		this.food2Preference;
		this.waitPreference;
		this.procreatePreference;
		this.procreateOwnSpeciesPreference;
		this.waitBonus;

	// animal init

		var fieldX = 10;
		var fieldY = 10;

		// created animals:
		if (father == null || mother == null) {
			this.energy = 100;
			this.sex = Math.floor(Math.random() * 2);
			this.age = Math.floor(Math.random() * 200); // should normally be 0
			this.positionX = Math.floor(Math.random() * (fieldX-2)) + 1;
			this.positionY = Math.floor(Math.random() * (fieldY-2)) + 1;		//borders should not be occupied

			this.food1Preference = Math.floor(Math.random() * 2000);
			this.food2Preference = Math.floor(Math.random() * 2000);

			this.food1Specialization = Math.floor(Math.random() * 1000);
			this.food2Specialization = Math.floor(Math.random() * 1000);

			//"künstliche Verteilung"
			/*if (Math.floor(Math.random() * 40) == 0)
			{
				this.food1Preference = 10;
				this.food1Specialization = 10;
			}
			if (Math.floor(Math.random() * 40) == 0)
			{
				this.food2Preference = 10;
				this.food2Specialization = 10;
			}*/

			this.waitPreference = Math.floor(Math.random() * 100);
			this.procreatePreference = Math.floor(Math.random() * 100);
			this.waitBonus = Math.floor(Math.random() * 500);
			//one of the parameters is fixed for reference:
			this.procreateOwnSpeciesPreference = 2000;

      this.move = function () {
        {
        	this.age += 1;
          //deduct energy for life
          this.reduceEnergy(this.food1Specialization * this.food1EnergyLossFactor); //should be around 20
          this.reduceEnergy(this.food2Specialization * this.food2EnergyLossFactor); //should be around 20

          // animal dies after 200 rounds or if energy is negative:
        	if(this.energy < 0 || this.age > 200)
        	{
        		this.die();
        	}
        	else
        	{
        	//decision is initiated
        		this.decide();
        	}

        	return self;
        }
      }

      this.reduceEnergy = function(reduction) {
        this.energy -= reduction;
      }

      this.die = function() {
        alert("animal dies");
      }

      this.decide = function() {
        alert("animal decides");
      }
		}

		// procreated animals:
		else {
			this.energy = 200;
			this.sex = Math.floor(Math.random() * 2);
			this.age = 0;
			// inheritance
			this.positionX = father.positionX;
			this.positionY = father.positionY;
			// - behaviour
			this.food1Preference = (father.food1Preference + mother.food1Preference)/2;
			this.food2Preference = (father.food2Preference + mother)/2;
			this.waitPreference = (father.waitPreference + mother.waitPreference)/2;
			this.procreatePreference = (father.procreatePreference + mother.procreatePreference)/2;
			this.procreateOwnSpeciesPreference = 2000;
			this.waitBonus = (father.waitBonus + mother.waitBonus)/2;
			// - form
			this.food1Specialization = (father.food1Specialization + mother.food1Specialization)/2;
			this.food2Specialization = (father.food2Specialization + mother.food2Specialization)/2;

			// mutation
			// - behaviour
			this.food1Preference = this.food1Preference * (1.200 - 0.400 * Math.random());
			this.food2Preference = this.food2Preference * (1.200 - 0.400 * Math.random());
			this.waitPreference = this.waitPreference * (1.200 - 0.400 * Math.random());
			this.procreatePreference = this.procreatePreference * (1.200 - 0.400 * Math.random());
			this.waitBonus = this.waitBonus * (1.200 - 0.400 * Math.random());
			// - form
			this.food1Specialization = this.food1Specialization * (1.200 - 0.400 * Math.random());
			this.food2Specialization = this.food2Specialization * (1.200 - 0.400 * Math.random());

		}
	// end animal init


	// animal methods

		this.eat = function (energy) {
			this.energy += energy;
		}

		this.energyUsage = function (energy) {
			this.energy -= energy;
		}

		this.aging = function (energy) {
			this.age++;
		}

		this.positionChange = function (changeX, changeY) {
			this.positionX += changeX;
			this.positionY += changeY;
		}

		this.alreadyMovedChanged = function (changeX, changeY) {
			this.alreadyMoved = !this.alreadyMoved;
		}

	// end animal methods

	}
}]);
