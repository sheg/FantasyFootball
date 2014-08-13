(function() {

  var app = angular.module('drafts', []);

  app.factory('Players', function() {
    return [
      {
        'first_name': 'Eli',
        'last_name': 'Manning',
        'position': 'QB',
        'team': 'NYG',
        'BYE': '5'
      },
      {
        'first_name': 'Alex',
        'last_name': 'Smith',
        'position': 'QB',
        'team': 'KC',
        'BYE': '4'
      },
      {
        'first_name': 'Frank',
        'last_name': 'Gore',
        'position': 'RB',
        'team': 'SF',
        'BYE': '8'
      }
    ];
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



//app.controller('LeadsController', ['$http', '$scope', function($http, $scope) {
//  $scope.lead = {};
//
//  $http.get("/v1/leads").success(function(data) {
//    $scope.leads = data;
//  });
//
//  $scope.addLead = function() {
//    $http.post('/v1/leads', { name: $scope.lead.name, email: $scope.lead.email }).success(function(data) {
//      $scope.leads.push(data);
//      $scope.lead = {};
//    });
//  };
//
//  $scope.deleteLead = function(leadIndex) {
//    var lead = $scope.leads[leadIndex];
//    var _confirm = confirm("Are you sure you want to delete " + lead.name + "?");
//    if(_confirm) {
//      $http.delete("/v1/leads/" + lead.id).success(function() {
//        $scope.leads.splice(leadIndex, 1);
//      });
//    }
//  };
//
//  $scope.clearLead = function() {
//    $scope.lead = {};
//    $('#new-lead-name').val('');
//    $('#new-lead-email').val('');
//    $scope.addLeadForm.$setPristine();
//  };
//}]);
