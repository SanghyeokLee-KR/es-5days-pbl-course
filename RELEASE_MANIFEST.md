# 학생 Public 저장소 일별 배포 매니페스트

| 공개 시점 | 공개 폴더 | 공개 전 필수 확인 |
|---|---|---|
| Day 1 전날 | `day-01/`, Docker 패키지 | `.env`·비밀번호·강사용 대본 제외 |
| Day 2 전날 | `day-02/` | 생성기 실행·Bulk 10,000건 검증 |
| Day 3 전날 | `day-03/`, 검색 요청·테스트 양식 | 요청 결과·PBL 변환 항목 검증 |
| Day 4 전날 | `day-04/` | Data View·Dashboard 기준·화면 확인 |
| Day 5 전날 | `day-05/`, 제출·발표 양식 | 미래 정답·평가 메모 제외 |

각 공개 직전 `QUALITY_GATES.md`의 공개 범위·명령 검증 항목을 점검한다.

현재 Day2 공개 경로: 교재는 `day-02/student-workbook.md`, 실습 안내·요청·작성 양식은 `day-02/practice/`다. 아래 최초 공개 기록의 v1은 이력 구분이며 학생이 선택할 별도 버전 폴더가 아니다.

## 2026-09-03 — Day 4 Kibana Dashboard 실습

- 학생교재, 8교시 실습가이드, Kibana 9.5.0 실제 화면 캡처 20종을 공개한다.
- Data View부터 각 패널·Control·저장·검증·백업까지 실제 클릭 순서를 담은 `KIBANA_9_5_STEP_BY_STEP.md`와 그래프 완성형 빠른 색인 `CHART_GALLERY.md`를 공개한다.
- 교시별 연습문제는 필수 4문제+선택 도전 1문제씩 총 40문제이며, 답안 작성 방법을 함께 제공한다.
- 공통 `products` 20,000건에서 Data View·Discover·KQL·Metric·Bar·Table·price custom ranges·Donut·Line·Dashboard·Control·Filter를 실습한다.
- 개인 PBL은 사용자·판단·질문4개·필요 field·데이터 적합성을 먼저 설계한 뒤 개인 Dashboard 4패널 이상과 상호작용 1개를 만든다.
- 개인 데이터가 부족한 학생은 공통 `products`로 기능 실습을 계속하고 부족 field·mapping type·값 분포·생성 규칙을 제출한다.
- Dashboard 핵심값 3개 교차 검증, 사용자 행동 2개, 오류 수정 1개, 결과3·한계2·필요 데이터1을 최종 근거로 남긴다.
- 강사용 PPT·대본·정답·평가 메모·실제 인증정보·Day5 자료는 제외한다.
- Kibana 9.5.0 기준 Donut(Pie의 Donut hole), 월 interval(`1M`), custom ranges, 패널 Settings/Inspect 위치를 확인하고 PDF를 필수 제출에서 제외했다.

## 2026-09-01 — Day 3 검색·품질 실습

- 학생교재, 검색 품질 점검표, 개인 evidence 양식을 공개한다.
- 공통 요청은 8교시×기본·변형·반례 3개, 총 24개다.
- 교시별 실습 문제지는 제공 코드 실행 1개·공통 API 직접 구현 2개·개인 PBL 2개씩 총 40문제다. 공통 요청 24개 파일은 참고 코드로 유지한다.
- 학생 최종 경로는 루트 `requests.http`(`V1-T17-P`~`V1-T21-P`), `docs/quality-test.md`, `evidence/day-03-search.md`다.
- 강사용 PPT·대본·정답·실제 인증정보·Day4~5 자료는 제외한다.

## 2026-09-01 — Day 2 v1

- 현재69장 강의용 학생교재, 실습/산출물 안내, 공통 요청, 개인 작성 양식.
- 공통12field mapping, 합성10000건·30건 표본·요약, 생성기·Bulk loader.
- 개인1000건 생성 템플릿, 로컬 데이터 검사, loader, 도서 참고 mapping/검증 요청.
- v2·구 실습·후속 Dashboard 참고·Day3~5·강사 대본/PPT/정답·실제 .env 제외.
- 기본 생성기 지원 범위와 같은ID 재적재 주의는 Day2 생성 가이드 참조.
