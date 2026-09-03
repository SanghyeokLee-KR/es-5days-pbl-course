# 검색 품질 점검표

각 행에 실제 PBL 검색 질문과 결과를 기록한다. 결과 수만 적지 않고 상위 결과가 질문 의도에 맞는지 확인한다.

| 번호 | 검색 질문 | 요청 파일/조건 | 기대 결과 | 실제 결과 요약 | 개선 여부·근거 |
|---|---|---|---|---|---|
| 1 | "시간 초과"가 언급된 로그를 찾고 싶다 | `requests.http` V1-T18-P-2, `match: {message: "시간 초과"}` | message에 "시간 초과"가 포함된 로그, 전체의 약 10% | `hits.total.value: 100` (전체 1000건 중 10.0%), 상위 5건 모두 "게이트웨이 응답이 3000ms 후 시간 초과되었습니다." 포함, highlight로 "시간" 토큰 강조 확인 | 개선함 — 처음엔 데이터 생성 설정 파일(`my-data-settings.ps1`)에 UTF-8 BOM이 없어 PowerShell 5.1이 한글 리터럴을 잘못 읽어 `message`가 깨졌고 검색이 1건만 나왔다. BOM을 추가해 재생성한 뒤 100건으로 정상화했다. |
| 2 | 결제 서비스에서 난 ERROR만 보고 싶다 | `requests.http` V1-T19-P-1, `bool.filter: [service_name=payment-api, log_level=ERROR]` | service_name=payment-api, log_level=ERROR인 로그만 | `hits.total.value: 20`, 확인한 5건 모두 두 조건을 만족 | 없음 — filter 2개로 정확히 좁혀짐 |
| 3 | 결제 서비스에서 처리 시간이 3초를 넘은 ERROR를 보고 싶다 | `requests.http` V1-T19-P-2, filter 3개(service_name·log_level·duration_ms) | payment-api·ERROR·duration_ms>3000인 로그, 정확히 3000인 경계 문서 여부 확인 | `gte:3000`과 `gt:3000` 둘 다 `hits.total.value: 8`로 동일 — duration_ms가 정확히 3000인 문서가 없다는 뜻 | 없음 — 경계 문서 부재를 두 요청 비교로 확인함 |

## 최소 기준

- 전문 검색 1개(질문 1), 정확 조건 검색 1개(질문 2의 `log_level` term), bool/filter 검색 1개(질문 2·3의 `bool.filter`) 포함
- filter 2개 이상: 질문 3에서 `service_name`·`log_level`·`duration_ms` 3개 적용
- sort 2개: `requests.http` V1-T20-P에서 `duration_ms desc` → `timestamp desc` 2차 정렬 적용
- 0건이어야 하는 조건 1개: `requests.http` V1-T21-P-2, 존재하지 않는 `log_id` 검색 시 `hits.total.value: 0`
- 예상과 다른 결과: 질문 1에서 `my-data-settings.ps1` 인코딩 문제를 발견해 수정함(위 표에 기록)
