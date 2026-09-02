# 데이터 생성 기록

- index: `shop-logs`
- 생성 건수: 1,000건 (표본 30건 별도 보존)
- seed: `20260901`
- 도구: `data/pbl-data-template/generator/generate-data.ps1`
- 설정 파일: `data/pbl-data-template/my-data-settings.ps1`
- mapping 검증: `-MappingFile ..\..\elasticsearch\index-create.json`로 생성 시점에 field/type 사전 확인
- 고정 사례: `-FixedDocumentsFile ..\sample-documents.json`으로 대표 3건을 1~3번 문서에 그대로 삽입 (업무 ID는 생성기 첫 3개 ID로 재배정)

## field 규칙 요약

| field | 방식 | 비율·범위 |
|---|---|---|
| `log_id` | id | `LOG-` + 6자리 순번 |
| `timestamp` | date | 2026-08-18 ~ 2026-09-01 사이 균등 분포 |
| `service_name` | choice | order-api / payment-api / catalog-api / auth-api 중 균등 |
| `log_level` | weighted_choice | INFO 70% · WARN 20% · ERROR 10% |
| `logger_name` | template | `com.shop.{service_name}.RequestHandler` |
| `message` | weighted_choice | 정상 70% · 재시도 15% · 시간 초과 10% · 오류 5% |
| `exception_class` | choice + 결측 90% | ERROR 비율(10%)에 맞춰 나머지는 비움 |
| `http_status` | weighted_choice | 200 75% · 404 5% · 500 10% · 504 10% |
| `duration_ms` | integer | 50 ~ 5000ms 균등 |
| `trace_id` | template | `TRC-{sequence}` |

## 알려진 한계

이 생성기는 field 간 조건부 상관관계를 지원하지 않는다. 그래서 `log_level=ERROR`와 `exception_class`·`http_status`가 실제로는 완전히 독립적으로 뽑힌다 — 현실에서는 ERROR일 때 예외 클래스가 항상 채워지지만, 이 데이터는 확률적으로만 비슷하게 맞춰져 있다. 검색 질문 검증(Day 3) 시 이 점을 감안한다.

## 검증 결과

- `validate-data.ps1` 로컬 검증: PASS (1000건, ID 중복 없음, mapping 일치)
- Bulk 적재 후 `_count`: 1000건 (생성 건수와 일치)
- `_search` aggregation 실측 분포: `log_level` INFO 711 / WARN 188 / ERROR 101, `service_name` 4개 서비스 239~261건으로 고른 분포 (대표 3건 고정 삽입 후 재측정)
- `duration_ms` stats: min 50.0 / max 4994.0 / avg 2557.98 (설정 범위 50~5000과 대체로 일치)
- 목표 비율(70/20/10)과 실측 비율(71.1/18.8/10.1)이 근접함을 확인

## 질문별 포함/제외/경계 사례

| 검색 질문 | 포함 사례 | 제외 사례 | 경계 사례 |
|---|---|---|---|
| "시간 초과" 언급 로그 검색 | `message`가 "게이트웨이 응답이 3000ms 후 시간 초과되었습니다."인 문서(약 10%, `LOG-000002` 고정 포함) | "요청 처리가 정상적으로 완료되었습니다."인 문서(약 70%) | "시간"만 있고 "초과"가 없는 문장은 생성하지 않음 — 검색어가 두 토큰이라 부분 일치 여부는 Day 3에 확인 |
| 결제 서비스의 느린 ERROR | `service_name=payment-api`·`log_level=ERROR`·`duration_ms>3000`(`LOG-000002` 고정 포함, `duration_ms=3021`) | 같은 조건이되 `duration_ms`가 3000 이하인 문서 | `duration_ms`가 정확히 3000인 경계값은 균등분포 특성상 고정 보장되지 않음 — Day 3에 실측 확인 필요 |
| 서비스별 에러 요약 | `log_level=ERROR`인 약 100건, 4개 서비스에 분산 | `log_level=INFO`인 약 700건 | 특정 서비스에 ERROR가 0건인 경우는 표본 크기(약 25건/서비스)상 발생 가능성이 낮으나 배제되지 않음 |

`log_id`·`http_status`·`exception_class`는 field 간 조건부 상관관계를 생성기가 지원하지 않아 완전히 연동되지 않는다(위 "알려진 한계" 참고). 그래서 위 표의 "포함 사례"는 고정 3건을 제외하면 확률적으로만 보장된다.
