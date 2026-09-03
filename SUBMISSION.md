# 최종 제출

- 학생 이름 / GitHub ID: 이상혁 / SanghyeokLee-KR
- 제출 시각: Day 5에 작성
- 평가 기준 commit SHA: Day 5에 작성
- 실행 확인 환경: Windows 11, Docker Desktop, Elasticsearch 9.5.0, Kibana 9.5.0
- Dashboard 캡처 경로: `evidence/day-04/common-dashboard.png`(공통 6패널), `evidence/day-04/personal-dashboard.png`(개인 6패널). 설계·검증 기록은 `evidence/day-04/dashboard-plan.md`, `evidence/day-04/dashboard-review.md`
- 알려진 제한 사항:
  - 공통·개인 Dashboard 모두 Control/Filter를 만들지 않아 `personal-dashboard-filtered.png`가 없다. 서비스(`service_name`)별로 나눠 보는 상호작용은 확인하지 못했다.
  - Day 3 7~8교시(`evidence/day-03-practice/period-07-quality.md`, `period-08-integration.md`)는 수업 진도가 6교시까지만 진행되어 미수행이다. 배포본 양식만 복사해 둔 상태다.
  - 공통 `products` 실제 문서 수가 10,000건으로 Day 4 가이드 기준값(20,000)과 다르다. `day-02` 배포 생성기 기본값이 10,000이고 `RELEASE_MANIFEST.md`의 Day 2 기록도 10,000건이라 교재 간 버전 불일치로 판단하고 실측값 기준으로 기록했다.
  - `message` 분석에 `nori` 플러그인이 없어 `standard` analyzer로 대체했다. 조사·어미가 분리되지 않아 "재시도"로 "재시도가"를 찾지 못한다.
  - 데이터 생성기가 field 간 조건부 상관관계를 지원하지 않아 `log_level=ERROR`와 `exception_class`·`http_status`가 완전히 연동되지 않는다. ERROR 101건 중 89건은 `exception_class`가 비어 있다.
  - Day 5 자료 미공개로 `docs/ai-search-decision.md`, `docs/retrospective.md`는 아직 작성하지 않았다.
