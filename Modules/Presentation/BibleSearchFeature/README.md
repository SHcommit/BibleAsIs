#  호홍홍

페이징에서 prefetch는 좀 단순하게 생각하자면 willDisplay 에서 재사용 큐 셀 꺼내져 올 때 dataSource.numberOfRows - 3 이정도 남으면 미리 데이터 fetch하고 인디케이터 추가해도될듯,,


### 마주한 이슈:
어후.. AVC에서 navigationItem.titleView에 searchController.searchBar넣고
어후.. BVC에서 navigationItem.titleView에 searchController.searchBar넣고.

AVC -> BVC로 push할 때 AVC에 있던 네비게이션 타이틀 뷰가 그대로 유지되어서 보여지는거 상당히 힘들었음.
+ BVC에서 키보드, 키보드 입력 딜레이 없이 자연스레 올라와서 first responder까지.. 

- https://stackoverflow.com/questions/27951965/cannot-set-searchbar-as-firstresponder 
이건 리스폰더 대응.
