# 쇼핑몰 백엔드 log4j 로그 트러블슈팅 PBL

## 1. 프로젝트 소개

- 문제와 사용자:
  장애 신고를 받은 백엔드 운영 담당자가
  서비스와 로그 레벨, 발생 시각으로 원인 로그를 찾는다.

- ES로 검색할 문서 1건:
  log4j2 JSON Layout으로 남은 로그 이벤트 1건

- 이 주제를 선택한 이유:
  메시지 본문 검색뿐 아니라 서비스·로그 레벨 조건과
  처리 시간 범위를 함께 적용하는 검색을 만들고 싶다.

> 강사 배포 자료 공개 현황: [Day 1](day-01/README.md), [Day 2](day-02/README.md), [Day 3](day-03/README.md), [Day 4](day-04/README.md). Day5는 순차 공개된다.

## 2. 검색 질문 초안

| 번호 | 사용자 질문 | 예상 조건 또는 결과 |
|---:|---|---|
| 1 | "시간 초과"가 언급된 로그를 찾고 싶다. | 메시지에 시간 초과가 포함된 로그 |
| 2 | 결제 서비스에서 난 ERROR만 보고 싶다. | 서비스=payment-api, 레벨=ERROR |
| 3 | 어느 서비스에서 에러가 많은지 알고 싶다. | 서비스별 ERROR 수 요약 |

> Day 2 데이터 준비 결과는 강사 배포 양식(`evidence/day-02-data.md`)을 따라 작성한다.
> Day 3에는 [교시별 실습 문제](day-03/practice/README.md) 8개 파일에서 공통 3문제와 개인 PBL 2문제씩 수행한다. 루트 `requests.http`에 `V1-T17-P`~`V1-T21-P` 요청을 추가하고, 품질 상세는 `docs/quality-test.md`, 일일 요약은 `evidence/day-03-search.md`에 작성한다.

> Day 4에는 [Kibana 9.5.0 화면 그대로 따라 하기](day-04/KIBANA_9_5_STEP_BY_STEP.md), [차트 완성형 한눈에 보기](day-04/CHART_GALLERY.md), [교시별 연습문제](day-04/practice/README.md)를 사용한다. 답은 개인 저장소의 `evidence/day-04-practice/`에, 최종 Dashboard 설계·검증은 `evidence/day-04/` 양식을 사용한다.

> 자신의 인덱스와 Search API를 브라우저에서 시연할 때는 [FE·BE 검색 앱 템플릿](search-app-template/README.md)을 사용한다. `search-app-template/`을 개인 PBL 저장소로 복사하고 설정 JSON 2개를 수정한 뒤 `start.ps1`을 실행한다. 적용 절차는 [APPLY_MY_INDEX_GUIDE.md](search-app-template/APPLY_MY_INDEX_GUIDE.md)를 따른다.

## 3. 결과에 보여 줄 값과 후보 조건

- 검색 결과 한 줄에 보여 줄 값: 발생 시각, 로그 레벨, 서비스명, 메시지, 처리 시간
- filter 후보: 서비스명, 로그 레벨, 예외 클래스
- 정렬 후보: 발생 시각, 처리 시간
- 데이터 규모 초안: 합성 로그 1,000건 (Day 2에 실제 생성·Bulk 적재 완료, seed `20260901`)

## 4. Day 2 데이터 확인

- index: `shop-logs` (`elasticsearch/index-create.json`)
- 데이터: 1,000건 생성·Bulk 적재 완료, count 일치
- 분포: log_level INFO 71.1% / WARN 18.8% / ERROR 10.1% (목표 70/20/10과 근접), duration_ms min 50 / max 4994
- 상세: [docs/data-model.md](docs/data-model.md), [docs/pipeline-decision.md](docs/pipeline-decision.md), [evidence/day-02-data.md](evidence/day-02-data.md)

## 5. Day 3 검색 확인

- index `shop-logs`에서 전문 검색·정확 조건·bool/filter·정렬 2개·highlight·의도한 0건까지 확인 완료
- "시간 초과" 전문 검색: 100건 (전체 10%와 일치)
- 결제 서비스 ERROR: 20건, 그중 3초 이상 지연: 3건
- 데이터 생성 설정 파일의 인코딩 문제(BOM 누락)로 검색어가 1건만 잡히던 것을 발견해 수정하고 재검증함
- 상세: [docs/quality-test.md](docs/quality-test.md), [evidence/day-03-search.md](evidence/day-03-search.md)

## 6. Day 1 환경 확인

- Docker Desktop: 확인 완료
- Kibana 접속: 확인 완료
- Console 첫 요청: 확인 완료

> 자세한 결과는 `evidence/day-01-environment.md`에 기록했다.

## 7. 실행·재현 순서

1. `day-01/docker`에서 `.env` 준비 후 `.\start.ps1`, `.\status.ps1`로 ES 3노드·Kibana 확인
2. `requests.http`의 V1-T12-P 요청으로 `shop-logs` index 생성 (mapping은 `elasticsearch/index-create.json`과 동일)
3. `data/pbl-data-template`에서
   ```powershell
   .\generator\generate-data.ps1 -SettingsFile .\my-data-settings.ps1 -MappingFile ..\..\elasticsearch\index-create.json -FixedDocumentsFile ..\sample-documents.json
   .\validate-data.ps1 -SettingsFile .\my-data-settings.ps1 -MappingFile ..\..\elasticsearch\index-create.json
   .\load-data.ps1 -SettingsFile .\my-data-settings.ps1 -MappingFile ..\..\elasticsearch\index-create.json -DockerDirectory "day-01\docker 실제 경로"
   ```
4. `requests.http`의 V1-T16-P, 검색 질문 1~2, V1-T17-P~V1-T21-P 요청으로 count·분포·검색 질문 확인

## 8. 제한 사항

- `data/pbl-data-template/generated/shop-logs-1000.ndjson`(전체 1,000건)은 제출하지 않는다. 위 절차대로 재생성하면 seed가 같아 동일하게 재현된다.
- 데이터 생성기가 field 간 조건부 상관관계를 지원하지 않아, `log_level=ERROR`와 `exception_class`/`http_status`가 완전히 연동되지는 않는다(`data/generation-notes.md` 참고).
- `message` 분석은 `nori` 플러그인 없이 `standard` analyzer로 대체했다.
