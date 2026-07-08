document.addEventListener('DOMContentLoaded', function() {
  var container = document.querySelector('.js-authority-map');
  if (!container || typeof L === 'undefined') return;

  var areaUrls;
  try {
    areaUrls = JSON.parse(container.getAttribute('data-area-urls'));
  } catch (e) {
    return;
  }
  if (!Array.isArray(areaUrls) || areaUrls.length === 0) return;

  var requests = areaUrls.map(function(url) {
    return fetch(url)
      .then(function(response) {
        if (!response.ok) throw new Error('Area request failed');
        return response.json();
      })
      .catch(function() { return null; });
  });

  Promise.all(requests).then(function(results) {
    var geometries = results.filter(function(geojson) {
      return geojson !== null;
    });
    // Leave the map hidden rather than show an empty world map
    if (geometries.length === 0) return;

    container.hidden = false;

    var map = L.map(container);
    map.attributionControl.setPrefix('');
    map.scrollWheelZoom.disable();

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: 'Map © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 18
    }).addTo(map);

    var areas = L.featureGroup().addTo(map);
    geometries.forEach(function(geojson) {
      var area = L.geoJSON(geojson);
      // Leaflet double click on an area doesn't zoom by default
      area.on('dblclick', function(e) {
        var zoom = map.getZoom() + (e.originalEvent.shiftKey ? -1 : 1);
        map.setZoomAround(e.containerPoint, zoom);
      });
      areas.addLayer(area);
    });

    map.fitBounds(areas.getBounds());
  });
});
