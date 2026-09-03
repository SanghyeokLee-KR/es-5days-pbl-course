# 개인 생성 규칙

## V1-T15-P 설정

- index / 업무 ID field / ID prefix: `shop-logs` / `log_id` / `LOG-`
- 첫 건수1000 / SampleCount30 / Seed: 1000 / 30 / `20260901`
- 코드·환경·설정 파일 위치: `data/pbl-data-template/generator/generate-data.ps1`, `data/pbl-data-template/my-data-settings.ps1`

| field | Kind | 후보/범위/비율 | 결측 정책 | mapping type | 연결 질문 |
|---|---|---|---|---|---|
| `log_id` | id | `LOG-` + 6자리 순번 | 없음 | keyword | 전체 |
| `timestamp` | date | 2026-08-18 ~ 2026-09-01 균등 분포 | 없음 | date | Q1, Q3 |
| `service_name` | choice | order-api / payment-api / catalog-api / auth-api 중 균등 | 없음 | keyword | Q2, Q3 |
| `log_level` | weighted_choice | INFO 70% · WARN 20% · ERROR 10% | 없음 | keyword | Q2, Q3 |
| `logger_name` | template | `com.shop.{service_name}.RequestHandler` | 없음 | keyword | - |
| `message` | weighted_choice | 정상 70% · 재시도 15% · 시간 초과 10% · 오류 5% | 없음 | text | Q1, Q3 |
| `exception_class` | choice | ERROR 비율(10%)에 맞춰 나머지는 비움 | 90% 결측 | keyword | - |
| `http_status` | weighted_choice | 200 75% · 404 5% · 500 10% · 504 10% | 없음 | integer | - |
| `duration_ms` | integer | 50 ~ 5000ms 균등 | 없음 | integer | Q3 |
| `trace_id` | template | `TRC-{sequence}` | 없음 | keyword | - |

## 포함·제외·경계

| 질문 | 포함 사례 | 제외 사례 | 경계 사례 | 고정 사례 사용 여부 | 확인 요청 |
|---|---|---|---|---|---|
| "시간 초과" 언급 로그 검색 | `message`가 "게이트웨이 응답이 3000ms 후 시간 초과되었습니다."인 문서(약 10%) | "요청 처리가 정상적으로 완료되었습니다."인 문서(약 70%) | "시간"만 있고 "초과"가 없는 문장은 생성 안 함 | 예(`LOG-000002`) | Day3 실측 100건으로 확인 완료 |
| 결제 서비스의 느린 ERROR | `service_name=payment-api`·`log_level=ERROR`·`duration_ms>3000`(`duration_ms=3021`) | 같은 조건이되 `duration_ms`가 3000 이하 | `duration_ms`가 정확히 3000인 문서는 균등분포상 보장 안 됨 | 예(`LOG-000002`) | Day3 실측 3건으로 확인 완료 |
| 서비스별 에러 요약 | `log_level=ERROR`인 약 100건, 4개 서비스에 분산 | `log_level=INFO`인 약 700건 | 특정 서비스 ERROR 0건은 표본크기(약 25건/서비스)상 가능성 낮으나 배제 안 됨 | 아니오 | Day3 실측 20건(payment-api ERROR)으로 확인 완료 |

- FixedDocumentsFile을 쓰면 업무 ID를 생성 ID로 다시 배정함을 확인: 예 — `LOG-000001`~`003`으로 재배정 확인함
- 복합 객체/연관 분포 등 미지원 요구와 선택한 범위/대안: field 간 조건부 상관관계(`log_level=ERROR`↔`exception_class`/`http_status`)를 생성기가 지원하지 않음. 각 field를 독립 확률로 생성하는 방식을 대안으로 씀 — 완전히 연동되진 않지만 목표 비율에는 근접함
- 생성·적재·검증 명령: `generate-data.ps1` → `validate-data.ps1` → `load-data.ps1` 순서로 실행
- 실제 분포와 예상의 차이 / 다음 수정: `validate-data.ps1` PASS(1000건, ID 중복 없음), Bulk 적재 후 `_count` 1000건 일치, `log_level` 목표(70/20/10) vs 실측(71.1/18.8/10.1) 근접, `duration_ms` min 50.0/max 4994.0/avg 2557.98 — 별도 수정 불필요
