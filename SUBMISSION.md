# 최종 제출

- 학생 이름 / GitHub ID: 이상혁 / SanghyeokLee-KR
- 제출 시각: Day 5에 작성
- 평가 기준 commit SHA: Day 5에 작성
- 실행 확인 환경: Windows 11, Docker Desktop, Elasticsearch 9.5.0, Kibana 9.5.0
- Dashboard 캡처 경로: `evidence/day-04/common-dashboard.png`(공통), `evidence/day-04/personal-dashboard.png`(개인). 설계랑 검증 기록은 `evidence/day-04/dashboard-plan.md`, `dashboard-review.md`
- 알려진 제한 사항:
  - Control이나 Filter를 안 만들어서 `personal-dashboard-filtered.png`가 없다. 서비스별로 나눠 보는 것도 못 했다
  - Day 3 7~8교시는 수업 진도가 6교시까지만 나가서 못 했다. 양식만 복사해 둔 상태다
  - 공통 products가 10,000건인데 Day 4 가이드는 20,000건 기준으로 쓰여 있다. day-02 생성기 기본값도 10,000이고 `RELEASE_MANIFEST.md`에도 10,000건으로 적혀 있어서 교재 쪽 불일치로 보고 실측값으로 기록했다
  - nori가 없어서 message를 standard analyzer로 돌렸다. 조사나 어미가 안 잘려서 "재시도"로 "재시도가"를 못 찾는다
  - 생성기가 field끼리 조건부로 엮는 걸 지원 안 해서 log_level=ERROR랑 exception_class, http_status가 따로 논다. ERROR 101건 중 89건은 exception_class가 비어 있다
  - Day 5 자료가 아직 안 올라와서 `docs/ai-search-decision.md`, `docs/retrospective.md`는 못 썼다
