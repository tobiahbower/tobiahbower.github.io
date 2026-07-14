-- ============================================================
-- Seed 001: Resume Content
-- Populate all tables with Tobiah Bower's resume data
-- Run AFTER 001_initial_schema.sql
-- Run: psql -d eportfolio -f 001_seed_resume.sql
-- ============================================================

BEGIN;

-- ── EDUCATION ─────────────────────────────────────────────
INSERT INTO education (degree, field, institution, gpa, start_year, end_year, honors, courses) VALUES
(
    'Master of Science',
    'Electrical Engineering',
    'University of Central Florida',
    4.00,
    2025,
    2026,
    ARRAY['IEEE Signal Processing Society Student Scholarship'],
    ARRAY[
        'Intro to Deep Learning',
        'Object Oriented Programming',
        'Computer Communication Networks',
        'Guidance, Navigation and Controls',
        'Estimation of Dynamical Systems',
        'Digital Control Systems',
        'Image Processing',
        'Digital Signal Processing Applications',
        'Surface Acoustic Wave Devices',
        'Intro to Applied Randomness',
        'Intro to Radar Systems',
        'Signal Analysis',
        'Analog Communication'
    ]
),
(
    'Bachelor of Science',
    'Electrical Engineering',
    'University of Central Florida',
    3.89,
    2021,
    2025,
    ARRAY[
        'National Merit Finalist',
        '6x President''s Honor Roll',
        'Burnett Honors College',
        '3x IEEE Signal Processing Society Student Scholarship'
    ],
    ARRAY[]::TEXT[]
);

-- ── EXPERIENCE ────────────────────────────────────────────
INSERT INTO experience (company, role, division, location, start_date, end_date, is_current) VALUES
(
    'Lockheed Martin',
    'GNC Engineer Asc',
    'Advanced Threat Warning Systems',
    'Orlando, FL',
    '2025-07-01',
    NULL,
    TRUE
),
(
    'Lockheed Martin',
    'Systems Engineering CWEP',
    'Advanced Threat Warning Systems',
    'Orlando, FL',
    '2025-01-01',
    '2025-04-30',
    FALSE
),
(
    'Lockheed Martin',
    'Systems Engineering CWEP',
    'Multi-Domain Missile Systems',
    'Orlando, FL',
    '2022-05-01',
    '2024-12-31',
    FALSE
),
(
    'University of Central Florida',
    'Honors Orientation Ambassador',
    'Burnett Honors College',
    'Orlando, FL',
    '2022-05-01',
    '2024-12-31',
    FALSE
);

-- Bullets for GNC Engineer (id=1)
INSERT INTO experience_bullets (experience_id, bullet, sort_order) VALUES
(1, 'Maintained PostgreSQL data tables for holistic system performance metrics, rearchitecting table links as necessary', 1),
(1, 'Designed simulation config file generator by design of experiment stratagem', 2),
(1, 'Created Python scripts to automatically populate database', 3),
(1, 'Created tool to plot training loss and examine node tree visit frequency and hit counts for random forest discriminator', 4),
(1, 'Developed track state covariance analysis, random forest discrimination, handtruthing, and navigation PSD modules for SPADE', 5),
(1, 'Pioneered inertial sensor POV coastlines and horizon line for SPADE video player; demoed to Systems Engineering AATC', 6),
(1, 'Created MATLAB tool for probability of detection analysis per missile shot; demoed to subject matter experts', 7),
(1, 'Generated stuck pixel heatmap for post non-uniformity correction on Gen III CAP3001 sensor', 8),
(1, 'Parallelized scoring MOPs and Probability of Detect tool insertion runs on atws-images cluster', 9),
(1, 'Generated technical measures of performance for missile warning and SAIRST flight test analysis', 10);

-- Bullets for CWEP ATWS (id=2)
INSERT INTO experience_bullets (experience_id, bullet, sort_order) VALUES
(2, 'Created distortion visualizer tool using radial basis function interpolation', 1),
(2, 'Developed handtruth-to-chip conversion MATLAB class and prototyped data input translator and module broker', 2),
(2, 'Introduced dynamic interfacing for newly launched SPADE tool', 3);

-- Bullets for CWEP Multi-Domain (id=3)
INSERT INTO experience_bullets (experience_id, bullet, sort_order) VALUES
(3, 'Enabled forward compatibility for JAGM mmWave terminal doppler imaging MATLAB tool', 1),
(3, 'Compiled JAGM integrated flight simulation surface danger zone results for Navy customer', 2),
(3, 'Generated Hellfire QALVT analysis suite: aero model validation, TM dropouts, modal analysis, Nav fusion', 3),
(3, 'Ran preflight predictions for QALVT using IFS Monte Carlo parameters for mass properties, wind, thrust misalignment', 4),
(3, 'Developed novel MATLAB telemetry analysis tool for Spike NLOS simulation', 5);

-- Bullets for UCF Ambassador (id=4)
INSERT INTO experience_bullets (experience_id, bullet, sort_order) VALUES
(4, 'Guided incoming EE/CpE/Optics students in course selection and plan of study', 1),
(4, 'Onboarded incoming freshmen into IEEE UCF, AIAA, and Knights Experimental Rocketry', 2);

-- ── PROJECTS ──────────────────────────────────────────────
INSERT INTO projects (title, category, description, start_date, end_date, repo_url, is_featured) VALUES
(
    'FORWARD — Omnidirectional Obstacle Avoidance',
    'Senior Design',
    'Wearable assistive device providing 2π steradian obstacle detection via ultrasonic and LiDAR sensors. Designed artificial potential field avoidance algorithm using YOLO detection datastream, IMU-based control feedback loop, 4-layer main controller PCB, and 2-layer voltage regulator PCB.',
    '2024-08-01', '2025-05-01', NULL, TRUE
),
(
    'VST Plugin Toolbox',
    'IEEE UCF',
    'Founded and led development of a virtual studio technology plugin suite for DAW deployment using C++ JUCE Framework. Oversaw UI design, backend delay line optimization, and implemented algorithmic convolutional reverb.',
    '2023-08-01', '2024-12-01', 'https://github.com/tobiahbower', FALSE
),
(
    'Airborne Doppler Radar Design Trade Study',
    'Coursework',
    'Comprehensive radar trade study examining effects of altitude, PRF, and atmospheric attenuation. Modeled radar cross section using polyfit; analyzed Pd, SNR, grazing angle, and radome rotation rate tradeoffs.',
    '2026-02-01', '2026-04-01', NULL, FALSE
),
(
    'Tailgate Speaker System',
    'IEEE UCF',
    'Led 3-phase development of integrated audio system with $1,000 budget. Custom MDF enclosure with 250W plate amplifier, 12-inch subwoofer, acoustic padding, and waterproofing.',
    '2022-08-01', '2023-08-01', NULL, FALSE
),
(
    'Super State Racer Hybrid EV',
    'IEEE UCF',
    'Software team member for hybrid energy electric vehicle. MATLAB Simulink model for Maxwell 48V 165F ultracapacitor discharge time; Python ODrive firmware for motor controller GPIO interfacing.',
    '2022-01-01', '2023-05-01', NULL, FALSE
),
(
    'Knight Light LED Drone Show',
    'IEEE UCF',
    'Co-founded and executed UCF''s first synchronized LED drone light show, coordinating hardware, firmware, and aerial choreography.',
    '2023-01-01', '2023-12-01', NULL, FALSE
);

INSERT INTO project_tags (project_id, tag) VALUES
(1,'YOLO'),(1,'LiDAR'),(1,'IMU'),(1,'KiCAD'),(1,'C++'),
(2,'C++'),(2,'JUCE'),(2,'DSP'),
(3,'MATLAB'),(3,'Radar'),(3,'Signal Processing'),
(4,'Audio'),(4,'Hardware'),(4,'Acoustics'),
(5,'MATLAB'),(5,'Python'),(5,'Simulink'),
(6,'Drones'),(6,'Embedded');

-- ── RESEARCH ──────────────────────────────────────────────
INSERT INTO research (title, lab, institution, description, start_date, end_date, status, venue, venue_year) VALUES
(
    'SPREN: Hybrid Speech Phase Reconstruction and Enhancement',
    'Autonomous and Intelligent Systems Laboratory',
    'University of Central Florida',
    'Developed and validated iterative (Kalman + GLA) and deep learning (Kalman + NSPP) hybrid approaches for speech phase reconstruction and enhancement. Novel Hausdorff phase retrieval trajectory analysis. Trade study of quality vs intelligibility as function of Kalman process noise Q.',
    '2024-12-01', NULL, 'submitted', 'Interspeech', 2026
),
(
    'Neural Prediction of Room Impulse Responses',
    NULL,
    'University of Central Florida',
    'Python codebase for batch training on energy decay curves, Schroeder frequency, and room dimensions to predict impulse responses. Live HuggingFace demo built for in-class presentation.',
    '2026-02-01', '2026-04-01', 'completed', NULL, NULL
),
(
    'Hybrid Magneto-Acoustic Wave Delay Lines',
    NULL,
    'University of Central Florida',
    'Designed hybrid SAW-MSW delay line combining YIG magnetostatic waves and LiNbO3 surface acoustic waves for tunable signal delay. Keysight ADS equivalent circuit simulation at 1 GHz; MATLAB side-lobe attenuation modeling.',
    '2024-10-01', '2024-12-01', 'completed', NULL, NULL
),
(
    'EKF / UKF Orbit Determination',
    NULL,
    'University of Central Florida',
    'Compared Extended and Unscented Kalman Filters for spacecraft orbit determination from ground-station range/azimuth/elevation measurements. UKF consistently outperformed EKF, especially at larger measurement intervals.',
    '2025-09-01', '2025-11-01', 'completed', NULL, NULL
),
(
    'Mobile Free Space Optical Communications',
    'Networking and Wireless Systems Laboratory',
    'University of Central Florida',
    'Constructed mobile half-duplex FSO communication platform. Arduino firmware reading photoresistor outputs for embedded irDA2 IR transceiver boards.',
    '2022-04-01', '2023-09-01', 'completed', NULL, NULL
),
(
    'Ionospheric Disturbance Metrics',
    'Central Florida Remote Sensing Laboratory',
    'University of Central Florida',
    'Aggregated HDF5 files for total electron content and scintillation data from madrigalWeb. Python script to download, extract, and plot ionospheric disturbance metrics.',
    '2022-02-01', '2022-05-01', 'completed', NULL, NULL
);

INSERT INTO research_tags (research_id, tag) VALUES
(1,'Kalman Filter'),(1,'GLA'),(1,'DNN'),(1,'Python'),(1,'PESQ'),(1,'STOI'),
(2,'Python'),(2,'Neural Networks'),(2,'Acoustics'),(2,'HuggingFace'),
(3,'Keysight ADS'),(3,'MATLAB'),(3,'RF/Microwave'),
(4,'MATLAB'),(4,'UKF'),(4,'EKF'),(4,'GNC'),
(5,'Arduino'),(5,'FSO'),(5,'Embedded'),
(6,'MATLAB'),(6,'Python'),(6,'HDF5');

-- ── SKILLS ────────────────────────────────────────────────
INSERT INTO skills (name, category, proficiency) VALUES
-- Programming
('MATLAB',   'Programming', 97),
('Python',   'Programming', 88),
('C/C++',    'Programming', 78),
('SQL',      'Programming', 75),
('Bash',     'Programming', 72),
('HTML/CSS', 'Programming', 65),
-- Domain
('Signal Processing',  'Domain Expertise', 95),
('Optimal Estimation', 'Domain Expertise', 90),
('GNC Systems',        'Domain Expertise', 88),
('Image Processing',   'Domain Expertise', 82),
('Deep Learning',      'Domain Expertise', 78),
('Radar Systems',      'Domain Expertise', 72),
-- Tools
('PostgreSQL',   'Tools', 80),
('Docker/Podman','Tools', 70),
('Git/GitLab',   'Tools', 85),
('Keysight ADS', 'Tools', 65),
('KiCAD/Eagle',  'Tools', 68),
('Jira/Agile',   'Tools', 75),
-- Hardware
('Oscilloscope', 'Hardware', 85),
('Soldering',    'Hardware', 80),
('PCB Design',   'Hardware', 75),
('Digital Mixer','Hardware', 90),
('Breadboarding','Hardware', 88);

-- ── ACTIVITIES ────────────────────────────────────────────
INSERT INTO activities (title, role, organization, start_date, end_date, url) VALUES
('Speech Phase Reconstruction Poster', 'Presenter', 'UCF Student Scholar Symposium', '2025-04-01', '2025-04-30', NULL),
('Super State Racer Poster',           'Presenter', 'UCF Student Scholar Symposium', '2023-04-01', '2023-04-30', NULL),
('IEEE UCF Officer',    'Vice President — Service, Professional Development, Project Lead', 'IEEE UCF', '2023-01-01', '2024-12-31', NULL),
('Digital Audio Workshops', 'Creator/Facilitator', 'IEEE UCF', '2023-08-01', '2023-12-31', NULL),
('ePortfolio Workshop',     'Creator/Facilitator', 'IEEE UCF', '2022-08-01', '2022-12-31', NULL),
('Knights Open Circuit Podcast', 'AV Editor/Scriptor', 'IEEE UCF', '2023-08-01', '2024-05-31', NULL),
('IEEE SoutheastCon', 'Team Lead', 'IEEE', '2023-01-01', '2024-12-31', NULL),
('Front-of-House Sound Engineering', 'Live Sound Engineer', 'Various', '2024-01-01', NULL, NULL),
('Livestream & Post-Production',     'Engineer / Lead',     'Various', '2025-01-01', NULL, NULL),
('Knight Light LED Drone Show', 'Co-Founder', 'IEEE UCF', '2023-01-01', '2023-12-31', NULL);

INSERT INTO schema_migrations (version) VALUES ('001_seed_resume')
    ON CONFLICT (version) DO NOTHING;

COMMIT;