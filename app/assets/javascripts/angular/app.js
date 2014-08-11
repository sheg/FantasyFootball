(function() {

  var app = angular.module('pointsLeaders', ['ngRoute', 'drafts']);

  app.config(['$routeProvider', function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: '/templates/draft.html',
        controller: 'DraftPlayersController'
      })
  }]);
})();