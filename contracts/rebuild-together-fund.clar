(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_PROJECT_NOT_FOUND u402)
(define-constant ERR_INSUFFICIENT_FUNDS u403)
(define-constant ERR_INVALID_AMOUNT u404)
(define-constant ERR_PROJECT_COMPLETED u405)
(define-constant ERR_ALREADY_VOLUNTEERED u406)
(define-constant ERR_INVALID_STATUS u407)
(define-constant ERR_CAMPAIGN_ENDED u408)
(define-constant ERR_MILESTONE_NOT_FOUND u409)
(define-constant ERR_INVALID_MILESTONE u410)

(define-constant PROJECT_STATUS_ACTIVE u0)
(define-constant PROJECT_STATUS_FUNDING u1)
(define-constant PROJECT_STATUS_BUILDING u2)
(define-constant PROJECT_STATUS_COMPLETED u3)
(define-constant PROJECT_STATUS_CANCELLED u4)

(define-constant PROJECT_TYPE_HOUSING u0)
(define-constant PROJECT_TYPE_INFRASTRUCTURE u1)
(define-constant PROJECT_TYPE_COMMUNITY_CENTER u2)
(define-constant PROJECT_TYPE_SCHOOL u3)
(define-constant PROJECT_TYPE_HEALTHCARE u4)

(define-constant MILESTONE_STATUS_PENDING u0)
(define-constant MILESTONE_STATUS_IN_PROGRESS u1)
(define-constant MILESTONE_STATUS_COMPLETED u2)
(define-constant MILESTONE_STATUS_VERIFIED u3)

(define-constant MIN_FUNDING_GOAL u1000000)
(define-constant MAX_FUNDING_GOAL u100000000)
(define-constant CAMPAIGN_DURATION u14400)
(define-constant VOLUNTEER_REWARD_RATE u50000)

(define-data-var project-counter uint u0)
(define-data-var milestone-counter uint u0)
(define-data-var total-funds-raised uint u0)
(define-data-var total-projects-completed uint u0)
(define-data-var contract-admin principal tx-sender)

(define-map rebuilding-projects uint {
    project-id: uint,
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    location: (string-ascii 100),
    project-type: uint,
    funding-goal: uint,
    current-funding: uint,
    status: uint,
    creation-date: uint,
    completion-date: (optional uint),
    volunteer-count: uint,
    milestone-count: uint
})

(define-map project-donations { project-id: uint, donor: principal } {
    total-donated: uint,
    first-donation-date: uint,
    last-donation-date: uint,
    donation-count: uint
})

(define-map project-volunteers { project-id: uint, volunteer: principal } {
    registration-date: uint,
    hours-contributed: uint,
    tasks-completed: uint,
    rewards-earned: uint,
    is-active: bool
})

(define-map project-milestones uint {
    milestone-id: uint,
    project-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 300),
    funding-required: uint,
    completion-reward: uint,
    status: uint,
    creation-date: uint,
    completion-date: (optional uint),
    assigned-volunteer: (optional principal)
})

(define-map donor-profiles principal {
    total-donated: uint,
    projects-supported: uint,
    first-donation-date: uint,
    reputation-score: uint
})

(define-map volunteer-profiles principal {
    total-hours: uint,
    projects-worked: uint,
    tasks-completed: uint,
    total-rewards: uint,
    reputation-score: uint,
    skills: (list 5 (string-ascii 50))
})

(define-map project-updates uint {
    update-id: uint,
    project-id: uint,
    author: principal,
    update-text: (string-ascii 500),
    update-date: uint,
    milestone-reference: (optional uint)
})

(define-public (create-rebuilding-project (title (string-ascii 100)) (description (string-ascii 500)) (location (string-ascii 100)) (project-type uint) (funding-goal uint))
    (let (
        (project-id (+ (var-get project-counter) u1))
    )
        (asserts! (>= funding-goal MIN_FUNDING_GOAL) (err ERR_INVALID_AMOUNT))
        (asserts! (<= funding-goal MAX_FUNDING_GOAL) (err ERR_INVALID_AMOUNT))
        (asserts! (<= project-type PROJECT_TYPE_HEALTHCARE) (err ERR_INVALID_STATUS))
        
        (map-set rebuilding-projects project-id {
            project-id: project-id,
            creator: tx-sender,
            title: title,
            description: description,
            location: location,
            project-type: project-type,
            funding-goal: funding-goal,
            current-funding: u0,
            status: PROJECT_STATUS_FUNDING,
            creation-date: burn-block-height,
            completion-date: none,
            volunteer-count: u0,
            milestone-count: u0
        })
        
        (var-set project-counter project-id)
        (ok project-id)
    )
)

(define-public (donate-to-project (project-id uint) (amount uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
        (existing-donation (default-to { total-donated: u0, first-donation-date: burn-block-height, last-donation-date: burn-block-height, donation-count: u0 }
                           (map-get? project-donations { project-id: project-id, donor: tx-sender })))
    )
        (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
        (asserts! (is-eq (get status project) PROJECT_STATUS_FUNDING) (err ERR_CAMPAIGN_ENDED))
        
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (map-set project-donations { project-id: project-id, donor: tx-sender } {
            total-donated: (+ (get total-donated existing-donation) amount),
            first-donation-date: (get first-donation-date existing-donation),
            last-donation-date: burn-block-height,
            donation-count: (+ (get donation-count existing-donation) u1)
        })
        
        (map-set rebuilding-projects project-id (merge project {
            current-funding: (+ (get current-funding project) amount)
        }))
        
        (var-set total-funds-raised (+ (var-get total-funds-raised) amount))
        (update-donor-profile tx-sender amount)
        
        (if (>= (+ (get current-funding project) amount) (get funding-goal project))
            (map-set rebuilding-projects project-id (merge project {
                current-funding: (+ (get current-funding project) amount),
                status: PROJECT_STATUS_ACTIVE
            }))
            true
        )
        
        (ok true)
    )
)

(define-public (volunteer-for-project (project-id uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
    )
        (asserts! (or (is-eq (get status project) PROJECT_STATUS_ACTIVE) (is-eq (get status project) PROJECT_STATUS_BUILDING)) (err ERR_INVALID_STATUS))
        (asserts! (is-none (map-get? project-volunteers { project-id: project-id, volunteer: tx-sender })) (err ERR_ALREADY_VOLUNTEERED))
        
        (map-set project-volunteers { project-id: project-id, volunteer: tx-sender } {
            registration-date: burn-block-height,
            hours-contributed: u0,
            tasks-completed: u0,
            rewards-earned: u0,
            is-active: true
        })
        
        (map-set rebuilding-projects project-id (merge project {
            volunteer-count: (+ (get volunteer-count project) u1),
            status: PROJECT_STATUS_BUILDING
        }))
        
        (update-volunteer-profile tx-sender project-id)
        (ok true)
    )
)

(define-public (create-milestone (project-id uint) (title (string-ascii 100)) (description (string-ascii 300)) (funding-required uint) (completion-reward uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
        (milestone-id (+ (var-get milestone-counter) u1))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (or (is-eq (get status project) PROJECT_STATUS_ACTIVE) (is-eq (get status project) PROJECT_STATUS_BUILDING)) (err ERR_INVALID_STATUS))
        (asserts! (>= (get current-funding project) funding-required) (err ERR_INSUFFICIENT_FUNDS))
        
        (map-set project-milestones milestone-id {
            milestone-id: milestone-id,
            project-id: project-id,
            title: title,
            description: description,
            funding-required: funding-required,
            completion-reward: completion-reward,
            status: MILESTONE_STATUS_PENDING,
            creation-date: burn-block-height,
            completion-date: none,
            assigned-volunteer: none
        })
        
        (map-set rebuilding-projects project-id (merge project {
            milestone-count: (+ (get milestone-count project) u1)
        }))
        
        (var-set milestone-counter milestone-id)
        (ok milestone-id)
    )
)

(define-public (assign-milestone (milestone-id uint) (volunteer principal))
    (let (
        (milestone (unwrap! (map-get? project-milestones milestone-id) (err ERR_MILESTONE_NOT_FOUND)))
        (project (unwrap! (map-get? rebuilding-projects (get project-id milestone)) (err ERR_PROJECT_NOT_FOUND)))
        (volunteer-registration (unwrap! (map-get? project-volunteers { project-id: (get project-id milestone), volunteer: volunteer }) (err ERR_UNAUTHORIZED)))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status milestone) MILESTONE_STATUS_PENDING) (err ERR_INVALID_STATUS))
        (asserts! (get is-active volunteer-registration) (err ERR_UNAUTHORIZED))
        
        (map-set project-milestones milestone-id (merge milestone {
            status: MILESTONE_STATUS_IN_PROGRESS,
            assigned-volunteer: (some volunteer)
        }))
        
        (ok true)
    )
)

(define-public (complete-milestone (milestone-id uint))
    (let (
        (milestone (unwrap! (map-get? project-milestones milestone-id) (err ERR_MILESTONE_NOT_FOUND)))
        (project (unwrap! (map-get? rebuilding-projects (get project-id milestone)) (err ERR_PROJECT_NOT_FOUND)))
        (volunteer-registration (unwrap! (map-get? project-volunteers { project-id: (get project-id milestone), volunteer: tx-sender }) (err ERR_UNAUTHORIZED)))
    )
        (asserts! (is-eq (some tx-sender) (get assigned-volunteer milestone)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status milestone) MILESTONE_STATUS_IN_PROGRESS) (err ERR_INVALID_STATUS))
        
        (map-set project-milestones milestone-id (merge milestone {
            status: MILESTONE_STATUS_COMPLETED,
            completion-date: (some burn-block-height)
        }))
        
        (map-set project-volunteers { project-id: (get project-id milestone), volunteer: tx-sender } (merge volunteer-registration {
            tasks-completed: (+ (get tasks-completed volunteer-registration) u1),
            rewards-earned: (+ (get rewards-earned volunteer-registration) (get completion-reward milestone))
        }))
        
        (try! (as-contract (stx-transfer? (get completion-reward milestone) tx-sender tx-sender)))
        (ok true)
    )
)

(define-public (verify-milestone (milestone-id uint))
    (let (
        (milestone (unwrap! (map-get? project-milestones milestone-id) (err ERR_MILESTONE_NOT_FOUND)))
        (project (unwrap! (map-get? rebuilding-projects (get project-id milestone)) (err ERR_PROJECT_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status milestone) MILESTONE_STATUS_COMPLETED) (err ERR_INVALID_STATUS))
        
        (map-set project-milestones milestone-id (merge milestone {
            status: MILESTONE_STATUS_VERIFIED
        }))
        
        (ok true)
    )
)

(define-public (complete-project (project-id uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status project) PROJECT_STATUS_BUILDING) (err ERR_INVALID_STATUS))
        
        (map-set rebuilding-projects project-id (merge project {
            status: PROJECT_STATUS_COMPLETED,
            completion-date: (some burn-block-height)
        }))
        
        (var-set total-projects-completed (+ (var-get total-projects-completed) u1))
        (ok true)
    )
)

(define-public (withdraw-funds (project-id uint) (amount uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (>= (get current-funding project) amount) (err ERR_INSUFFICIENT_FUNDS))
        (asserts! (or (is-eq (get status project) PROJECT_STATUS_ACTIVE) (is-eq (get status project) PROJECT_STATUS_BUILDING)) (err ERR_INVALID_STATUS))
        
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        
        (map-set rebuilding-projects project-id (merge project {
            current-funding: (- (get current-funding project) amount)
        }))
        
        (ok true)
    )
)

(define-public (add-project-update (project-id uint) (update-text (string-ascii 500)) (milestone-reference (optional uint)))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
        (update-id (+ (var-get project-counter) u1))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        
        (map-set project-updates update-id {
            update-id: update-id,
            project-id: project-id,
            author: tx-sender,
            update-text: update-text,
            update-date: burn-block-height,
            milestone-reference: milestone-reference
        })
        
        (ok update-id)
    )
)

(define-public (record-volunteer-hours (project-id uint) (volunteer principal) (hours uint))
    (let (
        (project (unwrap! (map-get? rebuilding-projects project-id) (err ERR_PROJECT_NOT_FOUND)))
        (volunteer-registration (unwrap! (map-get? project-volunteers { project-id: project-id, volunteer: volunteer }) (err ERR_UNAUTHORIZED)))
    )
        (asserts! (is-eq tx-sender (get creator project)) (err ERR_UNAUTHORIZED))
        (asserts! (> hours u0) (err ERR_INVALID_AMOUNT))
        
        (map-set project-volunteers { project-id: project-id, volunteer: volunteer } (merge volunteer-registration {
            hours-contributed: (+ (get hours-contributed volunteer-registration) hours),
            rewards-earned: (+ (get rewards-earned volunteer-registration) (* hours VOLUNTEER_REWARD_RATE))
        }))
        
        (try! (as-contract (stx-transfer? (* hours VOLUNTEER_REWARD_RATE) tx-sender volunteer)))
        (ok true)
    )
)

(define-private (update-donor-profile (donor principal) (amount uint))
    (let (
        (existing-profile (default-to { total-donated: u0, projects-supported: u0, first-donation-date: burn-block-height, reputation-score: u0 }
                          (map-get? donor-profiles donor)))
    )
        (map-set donor-profiles donor {
            total-donated: (+ (get total-donated existing-profile) amount),
            projects-supported: (+ (get projects-supported existing-profile) u1),
            first-donation-date: (get first-donation-date existing-profile),
            reputation-score: (+ (get reputation-score existing-profile) u5)
        })
        true
    )
)

(define-private (update-volunteer-profile (volunteer principal) (project-id uint))
    (let (
        (existing-profile (default-to { total-hours: u0, projects-worked: u0, tasks-completed: u0, total-rewards: u0, reputation-score: u0, skills: (list) }
                          (map-get? volunteer-profiles volunteer)))
    )
        (map-set volunteer-profiles volunteer (merge existing-profile {
            projects-worked: (+ (get projects-worked existing-profile) u1),
            reputation-score: (+ (get reputation-score existing-profile) u10)
        }))
        true
    )
)

(define-read-only (get-project (project-id uint))
    (map-get? rebuilding-projects project-id)
)

(define-read-only (get-project-donation (project-id uint) (donor principal))
    (map-get? project-donations { project-id: project-id, donor: donor })
)

(define-read-only (get-project-volunteer (project-id uint) (volunteer principal))
    (map-get? project-volunteers { project-id: project-id, volunteer: volunteer })
)

(define-read-only (get-milestone (milestone-id uint))
    (map-get? project-milestones milestone-id)
)

(define-read-only (get-donor-profile (donor principal))
    (map-get? donor-profiles donor)
)

(define-read-only (get-volunteer-profile (volunteer principal))
    (map-get? volunteer-profiles volunteer)
)

(define-read-only (get-project-update (update-id uint))
    (map-get? project-updates update-id)
)

(define-read-only (get-project-stats (project-id uint))
    (match (map-get? rebuilding-projects project-id)
        project (some {
            funding-progress: (if (> (get funding-goal project) u0)
                                (/ (* (get current-funding project) u100) (get funding-goal project))
                                u0),
            days-since-creation: (/ (- burn-block-height (get creation-date project)) u144),
            is-fully-funded: (>= (get current-funding project) (get funding-goal project)),
            volunteer-count: (get volunteer-count project),
            milestone-count: (get milestone-count project)
        })
        none
    )
)

(define-read-only (get-contract-stats)
    {
        total-projects: (var-get project-counter),
        total-milestones: (var-get milestone-counter),
        total-funds-raised: (var-get total-funds-raised),
        total-projects-completed: (var-get total-projects-completed),
        contract-admin: (var-get contract-admin)
    }
)