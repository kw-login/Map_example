var selectedMarker = []

function makeOverListener(map, marker, infowindow, normalImage, clickImage) {
    return function() {
        if (!selectedMarker.includes(marker)) {
            infowindow.open(map, marker);
            marker.setImage(clickImage);
            selectedMarker.push(marker);
        }
        else if(selectedMarker.includes(marker)){
            infowindow.close();
            marker.setImage(normalImage);
            let index = selectedMarker.indexOf(marker);
            if (index !== -1) {
                selectedMarker.splice(index, 1);
            }
        }
    };
}

window.onload = function () {
    var positions = [];
    // 현재 페이지의 URL을 가져옵니다.
    var url = window.location.href;

    // URL 객체를 생성합니다.
    var urlObj = new URL(url);

    // URL의 쿼리 문자열을 가져옵니다.
    var params = urlObj.searchParams;

    // 쿼리 문자열의 모든 키와 값을 출력합니다.
    var temp = [];
    for(let key of params.keys()) {
       temp.push(params.get(key));
       if(temp.length == 3) {
            let title = typeof temp[0] === 'string' ? temp[0] : String(temp[0])
            positions.push({
                title: title,
                latlng: new kakao.maps.LatLng(temp[2], temp[1])
            });
            temp = [];
       }
    }

    var mapContainer = document.getElementById('map'), // 지도를 표시할 div
        mapOption = {
            center: positions[0].latlng, // 지도의 중심좌표
            level: 3 // 지도의 확대 레벨
        };

    var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다

    // 마커 이미지의 이미지 주소입니다
    var imageSrc = "https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png";
    var clickImageSrc = "https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png";

    var i = 0;
    if (positions.length > 1) i += 1;
    for (; i < positions.length; i ++) {

        // 마커 이미지의 이미지 크기 입니다
        var imageSize = new kakao.maps.Size(96, 140);
        var clickImageSize = new kakao.maps.Size(192, 207);
//
        // 마커 이미지를 생성합니다
        var normalImage = new kakao.maps.MarkerImage(imageSrc, imageSize);
        var clickImage = new kakao.maps.MarkerImage(clickImageSrc, clickImageSize);

        // 마커를 생성합니다
        var marker = new kakao.maps.Marker({
            map: map, // 마커를 표시할 지도
            position: positions[i].latlng, // 마커를 표시할 위치
            //title : positions[i].title,
            image : normalImage // 마커 이미지
        });
//        marker.normalImage = normalImage;

        var width = 0;
        for(k = 0; k < positions[i].title.length; k ++) {
            width += 40;
        }
        width += 40;
        var infowindow = new kakao.maps.InfoWindow({
              content: '<div style="width: ' + width + 'px; height: 60px; padding:5px; font-size: 40px;">' + positions[i].title + '</div>', // 인포윈도우에 표시할 내용
        });

        kakao.maps.event.addListener(marker, 'click', makeOverListener(map, marker, infowindow, normalImage, clickImage));

//        'mouseover' 'mouseout' 액션은 웹 뷰 환경에서 동작 안함
//        kakao.maps.event.addListener(marker, 'mouseout', makeOutListener(infowindow));
    }

    var zoomControl = new kakao.maps.ZoomControl();
    map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);
}

const empty = (value) => {
    if (value === null) return true
    if (typeof value === 'undefined') return true
    if (typeof value === 'string' && value === '' && value === 'null') return true
    if (Array.isArray(value) && value.length < 1) return true
    if (typeof value === 'object' && value.constructor.name === 'Object' && Object.keys(value).length < 1 && Object.getOwnPropertyNames(value) < 1) return true
    if (typeof value === 'object' && value.constructor.name === 'String' && Object.keys(value).length < 1) return true // new String
    return false
}