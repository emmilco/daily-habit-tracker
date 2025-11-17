# Daily Habit Tracker

## PROJECT OVERVIEW

Single-page web application for daily habit tracking with automatic data collection to Google Sheets. Built with vanilla HTML/CSS/JavaScript - no build process or dependencies required.

**Tech Stack**: Vanilla HTML5, CSS3, JavaScript (ES6+)

**Entry Point**: `index.html` - complete self-contained application

## FILE STRUCTURE

```
/
├── index.html          # Complete application (HTML, CSS, JS in one file)
└── README.md          # Brief project description
```

**Architecture**: Single-file application with embedded styles and scripts
- All CSS in `<style>` block
- All JavaScript in `<script>` block
- No external dependencies or build tools
- Back button uses fixed positioning outside container to avoid layout shifts

## SETUP & USAGE

**No setup required** - open `index.html` directly in browser

**Deployment**:
- Static file hosting (GitHub Pages, Netlify, etc.)
- No build step needed
- Must be served over HTTPS for geolocation to work on mobile

**Local Testing**:
```bash
# Any simple HTTP server, e.g.:
python3 -m http.server 8000
# or
npx serve .
```

## DEVELOPMENT CONTEXT

**Application Flow**:
1. User progresses through 17 questions (yes/no and 1-5 scale)
2. Progress tracked with visual bar and counter
3. On completion, automatically submits to Google Apps Script endpoint
4. Collects UTC date/time and geolocation with responses

**Data Submission**:
- Google Apps Script URL configured in `APPS_SCRIPT_URL` constant
- Data format: comma-separated string (date, time, 17 answers, location)
- Submission happens automatically after last question

**Question Configuration**:
- Questions array in JavaScript
- 17 total questions: 12 yes/no, 5 scale (1-5)
- Fields: question1-12, scale1-5
- Questions maintain fixed vertical positioning regardless of text length (min-height on question text)

**Key Features**:
- **Back Navigation**: Large circular back button positioned below form (outside container) - appears after first question
- **Progress Bar**: Prominent gradient bar (36px) integrated into top edge of form with glossy overlay and soft bottom fade
- **Mobile-optimized**: Touch handling and responsive design
- Prevents iOS hover state issues
- Smooth transitions between questions with enter/exit animations
- Auto-advance after answer selection
- Geolocation capture with graceful degradation
- Answer preservation when navigating backward

**Customization Points**:
- Questions: Edit `questions` array in JavaScript
- Styling: Color scheme uses purple gradient (#667eea, #764ba2)
- Apps Script endpoint: Update `APPS_SCRIPT_URL` constant
- Total questions: Update `totalQuestions` constant
- Progress bar: Height and styling in `.progress-bar` and `.progress-fill` CSS
- Back button: Position calculated relative to viewport center with offset

**Layout Strategy**:
- Form container has fixed `min-height` to prevent layout shifts
- Question text uses `min-height` to keep buttons at consistent vertical position
- Back button positioned outside container with `position: fixed` to have zero impact on form layout
- Progress bar absolutely positioned at top edge of container

**Mobile Considerations**:
- Viewport locked to prevent zoom: `user-scalable=no`
- Double-tap zoom prevention
- Touch-specific hover state management
- Responsive breakpoints at 480px and landscape mode
- Back button position adjusted per breakpoint
