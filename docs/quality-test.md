# 검색 품질 점검표

각 행에 자신의 PBL 검색 질문과 실제 결과를 기록합니다. 결과 수만 적지 말고, 상위 결과가 질문 의도에 맞는지 확인합니다.

| 번호 | 검색 질문 | 요청 파일/조건 | 기대 결과 | 실제 결과 요약 | 개선 여부·근거 |
|---|---|---|---|---|---|
| 1 | "시간 초과"가 언급된 로그를 찾고 싶다 | `requests.http` V1-T18-P-2, `match: {message: "시간 초과"}` | message에 "시간 초과" 있는 로그, 전체 10%쯤 | 100건(1000건 중 10.0%). 상위 5건 다 "게이트웨이 응답이 3000ms 후 시간 초과되었습니다.", highlight로 "시간" 토큰 | 개선함. `my-data-settings.ps1`에 UTF-8 BOM이 없어 message가 깨져 1건만 나왔고, BOM 넣고 재생성 후 100건 |
| 2 | 결제 서비스에서 난 ERROR만 보고 싶다 | `requests.http` V1-T19-P-1, `bool.filter: [service_name=payment-api, log_level=ERROR]` | payment-api이면서 ERROR인 로그만 | 20건. 확인한 5건 다 두 조건 만족 | 없음 |
| 3 | 결제 서비스에서 처리 시간이 3초를 넘은 ERROR를 보고 싶다 | `requests.http` V1-T19-P-2, filter 3개(service_name, log_level, duration_ms) | payment-api, ERROR, duration_ms 3000 초과. 경계값 확인 | `gte:3000`과 `gt:3000` 둘 다 8건. duration_ms가 딱 3000인 문서 없음 | 없음 |

## 최소 기준

- 전문 검색: 질문 1 / 정확 조건: 질문 2의 log_level term / bool·filter: 질문 2, 3의 bool.filter
- filter 2개 이상: 질문 3에서 service_name, log_level, duration_ms 3개
- sort 2개: `requests.http` V1-T20-P의 duration_ms desc, timestamp desc
- 0건이어야 하는 조건 1개: `requests.http` V1-T21-P-2, 없는 log_id로 검색 시 0건
- 예상과 다른 결과: 질문 1의 인코딩 문제(위 표)
