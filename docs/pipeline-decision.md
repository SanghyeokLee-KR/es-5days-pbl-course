# V1-T16-P pipeline 판단

- 선택: 미적용
- 대상 field / 입력 예 / 출력 예: 해당 없음(미적용). 적용했다면 비정형 로그 원문이 입력, 구조화된 JSON field가 출력이었겠지만 이미 구조화된 채로 생성함
- 원본 보존 여부: 해당 없음(pipeline 미사용)
- 생성 단계 / 애플리케이션 / 서버 pipeline 중 처리 위치: 생성 단계에서 이미 올바른 type·구조로 만듦
- 선택 이유와 대안 비교: 데이터가 log4j2 JSON Layout으로 이미 field 단위로 구조화돼 있어 원문 텍스트를 grok으로 쪼개는 파싱 단계가 필요 없다. `timestamp`·`duration_ms`·`http_status` 모두 생성 시점에 올바른 type으로 만들어져 `convert` 프로세서가 필요 없다. `exception_class`는 ERROR가 아닌 문서에서 비워 두면 되고, 값이 있을 때 이미 정확한 클래스명이라 가공이 필요 없다.
- 일회/반복 여부 외에 고려한 조건: 데이터가 배치 생성이라 재처리 빈도는 고려 대상이 아니었다
- 적용한 경우 정의·simulate·실제 임시 단건 요청 위치: 해당 없음(미적용). 대신 공통 `product-cleanup` pipeline simulate로 pipeline 동작 자체는 `requests.http`의 V1-T16-C에서 별도 확인했다
- 실제 결과 및 임시 문서 정리 확인: 해당 없음
- 미적용/보류라면 대체 방법과 재검토 조건: 실제 운영 로그를 원문 텍스트(비정형 라인) 그대로 수집하게 되면, 그때는 `grok` 또는 `dissect` 프로세서로 `timestamp`·`log_level`·`service_name`을 추출하는 pipeline이 필요하다. 지금은 합성 데이터를 애초에 구조화된 JSON으로 생성하므로 해당 없음.

개인 데이터1000건 적재/분포 검증은 이 선택과 별개로 필수다.
