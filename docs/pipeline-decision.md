# V1-T16-P pipeline 판단

- 선택: 미적용
- 대상 field / 입력 예 / 출력 예: 없음
- 원본 보존 여부: 해당 없음
- 생성 단계 / 애플리케이션 / 서버 pipeline 중 처리 위치: 생성 단계. 만들 때부터 type을 맞춰서 뽑았다
- 선택 이유와 대안 비교: 데이터가 log4j2 JSON Layout이라 이미 field로 나뉘어 있다. grok으로 원문을 쪼갤 게 없다. timestamp, duration_ms, http_status도 생성할 때 type을 맞춰놔서 convert도 필요 없었다. exception_class는 ERROR가 아니면 비워두면 된다.
- 일회/반복 여부 외에 고려한 조건: 배치로 한 번에 만드는 데이터라 재처리 빈도는 볼 필요가 없었다
- 적용한 경우 정의·simulate·실제 임시 단건 요청 위치: 없음. pipeline이 어떻게 동작하는지는 공통 product-cleanup simulate로 봤다 (`requests.http` V1-T16-C)
- 실제 결과 및 임시 문서 정리 확인: 해당 없음
- 미적용/보류라면 대체 방법과 재검토 조건: 나중에 진짜 운영 로그를 텍스트 그대로 받게 되면 grok이나 dissect로 timestamp, log_level, service_name을 뽑아내야 한다

개인 데이터1000건 적재/분포 검증은 이 선택과 별개로 필수다.
