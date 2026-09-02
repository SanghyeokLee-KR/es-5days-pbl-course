# Ingest Pipeline 적용 판단

## 결론

미적용.

## 근거

- 데이터가 log4j2 JSON Layout으로 이미 field 단위로 구조화되어 있어, 원문 텍스트를 grok으로 쪼개는 파싱 단계가 필요 없다.
- `timestamp`, `duration_ms`, `http_status` 모두 생성 시점에 올바른 type으로 만들어지므로 `convert` 프로세서가 필요 없다.
- `exception_class`는 ERROR가 아닌 문서에서 비워 두면 되고, 값이 있을 때 이미 정확한 클래스명이라 가공이 필요 없다.

## 향후 검토 조건

실제 운영 로그를 원문 텍스트(비정형 라인) 그대로 수집하게 되면, 그때는 `grok` 또는 `dissect` 프로세서로 `timestamp`·`log_level`·`service_name`을 추출하는 pipeline이 필요하다. 지금은 합성 데이터를 애초에 구조화된 JSON으로 생성하므로 해당 없음.
