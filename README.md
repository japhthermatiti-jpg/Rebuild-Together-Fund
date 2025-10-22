# 🏠 Rebuild Together Fund

A comprehensive blockchain-based community rebuilding platform built on the Stacks blockchain, enabling collaborative funding, volunteer coordination, and milestone-driven project management for community reconstruction and development initiatives.

## 🚀 Features

- **Community Project Creation** 🏢: Create rebuilding projects for housing, infrastructure, schools, and community centers
- **Crowdfunding Campaigns** 💰: Community-driven funding with transparent goal tracking
- **Volunteer Coordination** 👥: Register volunteers and track their contributions with reward systems
- **Milestone Management** 🎯: Break projects into manageable milestones with completion rewards
- **Progress Tracking** 📈: Real-time project updates and milestone verification
- **Reputation System** ⭐: Build reputation for donors and volunteers through community participation
- **Multi-Category Support** 🏷️: Housing, infrastructure, community centers, schools, and healthcare projects
- **Transparent Analytics** 📊: Comprehensive project statistics and community impact tracking

## 📁 Project Structure

```
Rebuild-Together-Fund/
├── contracts/
│   └── rebuild-together-fund.clar    # Main smart contract
├── tests/
│   └── rebuild-together-fund.test.ts # TypeScript tests
├── Clarinet.toml                     # Project configuration
└── README.md                         # This file
```

## 🛠️ Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Quick Start
```bash
# Clone the repository
git clone <your-repo-url>
cd Rebuild-Together-Fund

# Check contract syntax
clarinet check

# Run tests
npm install
npm test

# Start local development network
clarinet integrate
```

## 📖 Contract Functions

### Public Functions

#### Project Management
- `create-rebuilding-project` - Create new community rebuilding projects with funding goals
- `complete-project` - Mark projects as completed (project creator only)
- `withdraw-funds` - Withdraw project funds for construction expenses (creator only)
- `add-project-update` - Post progress updates with optional milestone references

#### Funding Operations
- `donate-to-project` - Contribute STX to rebuilding projects with automatic goal tracking

#### Volunteer Coordination
- `volunteer-for-project` - Register as a volunteer for active projects
- `record-volunteer-hours` - Track volunteer work hours with automatic rewards (creator only)

#### Milestone System
- `create-milestone` - Define project milestones with funding requirements and rewards
- `assign-milestone` - Assign milestones to registered volunteers (creator only)
- `complete-milestone` - Mark milestones as completed and earn rewards (assigned volunteer only)
- `verify-milestone` - Verify completed milestones (project creator only)

### Read-Only Functions
- `get-project` - Retrieve complete project information and status
- `get-project-donation` - View donation records for specific donors and projects
- `get-project-volunteer` - Check volunteer registration and contribution details
- `get-milestone` - Access milestone information and completion status
- `get-donor-profile` - View donor statistics and reputation scores
- `get-volunteer-profile` - Access volunteer profiles with skills and achievements
- `get-project-update` - Read project updates and progress reports
- `get-project-stats` - Get comprehensive project analytics and metrics
- `get-contract-stats` - Platform-wide statistics and community impact data

## 🎯 Usage Examples

### Creating a Rebuilding Project
```clarity
(contract-call? .rebuild-together-fund create-rebuilding-project
  "Community Center Restoration"                    ;; Project title
  "Rebuild and modernize the historic community center damaged by recent storms, including new roof, updated electrical systems, and ADA accessibility improvements"  ;; Description
  "Springfield, Ohio"                              ;; Location
  u2                                                 ;; Community center type
  u25000000                                         ;; Funding goal: 25 STX
)
```

### Donating to a Project
```clarity
(contract-call? .rebuild-together-fund donate-to-project
  u1        ;; Project ID
  u3000000  ;; Donate 3 STX
)
```

### Volunteering for a Project
```clarity
(contract-call? .rebuild-together-fund volunteer-for-project
  u1  ;; Project ID
)
```

### Creating a Milestone
```clarity
(contract-call? .rebuild-together-fund create-milestone
  u1                                    ;; Project ID
  "Foundation Repair"                   ;; Milestone title
  "Complete foundation assessment and structural repairs including waterproofing and crack sealing"  ;; Description
  u5000000                             ;; Funding required: 5 STX
  u500000                              ;; Completion reward: 0.5 STX
)
```

### Assigning a Milestone to Volunteer
```clarity
(contract-call? .rebuild-together-fund assign-milestone
  u1                              ;; Milestone ID
  'SP-VOLUNTEER-PRINCIPAL-ADDRESS ;; Volunteer address
)
```

### Completing a Milestone (Volunteer)
```clarity
(contract-call? .rebuild-together-fund complete-milestone
  u1  ;; Milestone ID
)
```

### Verifying a Milestone (Project Creator)
```clarity
(contract-call? .rebuild-together-fund verify-milestone
  u1  ;; Milestone ID
)
```

### Recording Volunteer Hours
```clarity
(contract-call? .rebuild-together-fund record-volunteer-hours
  u1                              ;; Project ID
  'SP-VOLUNTEER-PRINCIPAL-ADDRESS ;; Volunteer address
  u8                              ;; 8 hours of work
)
```

### Adding Project Update
```clarity
(contract-call? .rebuild-together-fund add-project-update
  u1                                    ;; Project ID
  "Completed roof repairs and started electrical work. Weather has been favorable and we are ahead of schedule."  ;; Update text
  (some u1)                            ;; Reference to milestone ID (optional)
)
```

## 📊 Project Status Flow

```
FUNDING (1) → Goal Reached → ACTIVE (0) → Volunteers Join → BUILDING (2) → COMPLETED (3)
     ↓                                                                              ↓
CANCELLED (4)                                                                  CANCELLED (4)
```

## 🏷️ Project Types

```
HOUSING (0)          - Residential construction and repairs
INFRASTRUCTURE (1)   - Roads, bridges, utilities, and public works
COMMUNITY_CENTER (2) - Community buildings and gathering spaces
SCHOOL (3)           - Educational facilities and improvements
HEALTHCARE (4)       - Medical facilities and health infrastructure
```

## 🏋️ Milestone Status Flow

```
PENDING (0) → Assignment → IN_PROGRESS (1) → COMPLETED (2) → VERIFIED (3)
```

## 💼 Business Model

### Funding Structure
- **Minimum Goal**: 1 STX minimum funding goal to prevent spam projects
- **Maximum Goal**: 100 STX maximum to ensure reasonable project scope
- **Campaign Duration**: 14,400 blocks (~100 days) for fundraising
- **Volunteer Rewards**: 0.05 STX per hour worked plus milestone completion bonuses

### Project Lifecycle
- **Funding Phase**: Community donations until goal is reached
- **Active Phase**: Project becomes active when fully funded
- **Building Phase**: Volunteers register and work begins
- **Completion**: Project creator marks project as completed

## 🔒 Security Features

- **Creator Controls**: Only project creators can manage their projects and milestones
- **Volunteer Verification**: Only registered volunteers can be assigned milestones
- **Milestone Authorization**: Only assigned volunteers can complete their milestones
- **Fund Protection**: Creator authorization required for fund withdrawals
- **Contribution Tracking**: Transparent tracking of all donations and volunteer hours
- **Reputation System**: Anti-fraud measures through reputation scoring
- **Status Validation**: Proper project status transitions enforced

## 💡 Use Cases

### Disaster Recovery
- **Hurricane Rebuilding**: Coordinate community rebuilding after natural disasters
- **Fire Recovery**: Restore buildings and infrastructure after wildfire damage
- **Flood Restoration**: Repair and rebuild flood-damaged community assets
- **Earthquake Reconstruction**: Reconstruct earthquake-damaged infrastructure

### Community Development
- **Affordable Housing**: Build and repair affordable housing units
- **Infrastructure Improvement**: Upgrade roads, utilities, and public facilities
- **Educational Facilities**: Construct and renovate schools and libraries
- **Healthcare Access**: Build clinics and health centers in underserved areas

### Historic Preservation
- **Historic Buildings**: Restore and preserve historic community landmarks
- **Cultural Centers**: Rebuild cultural and arts facilities
- **Religious Buildings**: Restore churches, temples, and community worship spaces
- **Community Parks**: Develop and maintain recreational spaces

### Economic Development
- **Small Business Recovery**: Rebuild commercial districts and small businesses
- **Job Training Centers**: Construct workforce development facilities
- **Community Markets**: Build farmers markets and local commerce hubs
- **Technology Centers**: Create community technology and innovation spaces

## 🎨 Stakeholder Benefits

### For Project Creators
- **Funding Access** 💰: Raise funds for community rebuilding projects
- **Volunteer Coordination** 👥: Organize and manage volunteer workforce
- **Progress Management** 📈: Track project milestones and completion
- **Community Engagement** 🤝: Build community support and participation
- **Transparent Operations** 🔍: All activities publicly verifiable

### For Donors
- **Impact Visibility** 🎯: See exactly how donations are used
- **Community Investment** 🏠: Invest in local community development
- **Reputation Building** ⭐: Build donor reputation through consistent giving
- **Tax Benefits** 📄: Immutable donation records for tax purposes
- **Global Reach** 🌍: Support rebuilding projects worldwide

### For Volunteers
- **Skill Development** 🚀: Learn construction and project management skills
- **Earned Rewards** 💰: Receive STX compensation for volunteer work
- **Community Service** 🎆: Contribute to meaningful community projects
- **Network Building** 🤝: Connect with like-minded community members
- **Achievement Tracking** 🏆: Build portfolio of community service

### For Communities
- **Rapid Recovery** ⚡: Accelerated rebuilding through coordinated efforts
- **Local Ownership** 🏡: Community-controlled rebuilding processes
- **Skill Retention** 📚: Local volunteers learn valuable construction skills
- **Economic Stimulus** 📈: Local spending and employment opportunities
- **Social Cohesion** 🤝: Strengthen community bonds through shared projects

## 📈 Platform Analytics

The contract provides comprehensive analytics:
- **Project Performance**: Track funding success rates and completion times
- **Community Engagement**: Monitor volunteer participation and hour contributions
- **Funding Patterns**: Analyze donation trends and donor behavior
- **Geographic Impact**: Track rebuilding efforts across different locations
- **Skill Development**: Monitor volunteer skill building and career progression
- **Economic Impact**: Measure total funds deployed and projects completed

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

Tests cover:
- Project creation and funding workflows
- Volunteer registration and coordination
- Milestone creation, assignment, and completion
- Fund management and withdrawal processes
- Progress tracking and update systems
- Reputation system functionality
- Security controls and access validation
- Error handling and edge cases

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 401 | ERR_UNAUTHORIZED | Access denied for operation |
| 402 | ERR_PROJECT_NOT_FOUND | Project ID doesn't exist |
| 403 | ERR_INSUFFICIENT_FUNDS | Insufficient funds for operation |
| 404 | ERR_INVALID_AMOUNT | Invalid amount specified |
| 405 | ERR_PROJECT_COMPLETED | Project already completed |
| 406 | ERR_ALREADY_VOLUNTEERED | User already volunteered for project |
| 407 | ERR_INVALID_STATUS | Invalid status for operation |
| 408 | ERR_CAMPAIGN_ENDED | Funding campaign has ended |
| 409 | ERR_MILESTONE_NOT_FOUND | Milestone ID doesn't exist |
| 410 | ERR_INVALID_MILESTONE | Invalid milestone parameters |

## 🌟 Platform Benefits

- **Decentralized Coordination** 🏛️: No central authority controls rebuilding efforts
- **Transparent Operations** 📊: All funding and work publicly verifiable
- **Global Participation** 🌐: Anyone worldwide can contribute to rebuilding efforts
- **Automated Incentives** 🤖: Smart contracts handle volunteer compensation
- **Community Ownership** 🏡: Local communities control their rebuilding priorities
- **Rapid Response** ⚡: Quick deployment of resources during emergencies
- **Permanent Records** 📜: Immutable record of all rebuilding activities

## 🎯 Target Communities

- **Disaster-Affected Areas**: Communities recovering from natural disasters
- **Rural Communities**: Remote areas needing infrastructure development
- **Urban Renewal**: Cities revitalizing neglected neighborhoods
- **Historic Districts**: Communities preserving historic buildings and landmarks
- **Developing Regions**: Areas lacking basic infrastructure and facilities
- **Indigenous Communities**: Tribal lands developing community infrastructure
- **Refugee Settlements**: Temporary and permanent refugee community development

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Run `clarinet check` to validate
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For questions or support:
- Create an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Visit the [Clarinet documentation](https://docs.hiro.so/stacks/clarinet-js-sdk)

## 🚀 Deployment

Ready for deployment on:
- **Stacks Testnet**: For testing and development
- **Stacks Mainnet**: For production community rebuilding

---

Built with ❤️ for community rebuilding and collective action using Stacks blockchain technology.
