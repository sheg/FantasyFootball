(function() {

  var app = angular.module('drafts', []);

  app.factory('Players', function($http) {
    var model = this;

    $http.get("http://api.pointsleaders-dev.com:3000/v1/players").success(function(data) {
      return model.playerData = data;
    });

    return model;
  });


  app.controller('DraftPlayersController', ['$scope', 'Players', function($scope, players) {
    $scope.players = players;
    $scope.selectedPlayer = {};

    $scope.selectPlayer = function(player) {
      $scope.selectedPlayer = player;
    };

    $scope.isPlayerSelected = function() {
      return !($.isEmptyObject($scope.selectedPlayer));
    };

    $scope.playerFullName = function(player) {
      return player.last_name + ", " + player.first_name;
    };
  }]);

})();