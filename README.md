# Car Recommendation API

A Ruby on Rails API that provides car recommendations based on user preferences and external ranking scores.

## Overview

This API endpoint delivers personalized car recommendations by:
- Matching cars with user's preferred brands and price ranges
- Incorporating external recommendation scores
- Sorting results by match quality and price
- Supporting pagination and filtering options

## Technical Details

### Architecture

![image](https://github.com/user-attachments/assets/90cc3de5-ee9a-4f8a-938d-6d6f32f8d3fe)

The application follows a service-oriented architecture with:

1. Controllers (API/V1)
   - Handle HTTP requests
   - Basic parameter validation
   - Error responses

2. Services
   - CarQueryService: Main business logic for filtering and sorting cars
   - LabelService: Determines match quality labels
   - RecommendationCacheService: Handles external recommendation data

3. Models
   - Car: Core vehicle data
   - Brand: Brand information
   - User: User preferences and settings

### Key Features

1. Smart Sorting Algorithm
   - Perfect matches (preferred brand + price range)
   - Good matches (preferred brand only)
   - Recommendation scores
   - Price ordering

2. Performance Optimizations
   - Database-level sorting and filtering
   - Eager loading of associations
   - Pagination support
   - SQL query optimization

3. Filtering Options
   - Brand name search
   - Price range filters
   - Pagination controls

## API Documentation

### GET /api/v1/cars

Parameters:
- user_id (required): ID of the user for preferences
- query (optional): Filter by brand name
- price_min (optional): Minimum price filter
- price_max (optional): Maximum price filter
- page (optional): Page number for pagination

Response Format:

```json
[
  {
    "id": 1,
    "brand": {
    "id": 1,
    "name": "Toyota"
    },
    "model": "Camry",
    "price": 25000,
    "rank_score": 0.95,
    "label": "perfect_match"
  }
]
```

## Testing

The application includes comprehensive test coverage:
- Request specs for API endpoints
- Service unit tests
- Model specs for business logic
- Integration tests for full functionality

## Setup

1. Clone the repository
2. Install dependencies:
   ```
   bundle install
   ```
3. Setup database:
   ```
   rails db:create db:migrate
   ```
4. Run the test suite:
   ```
   rspec
   ```

## Dependencies

### Core
- Ruby 2.7.2
- Rails 6.1.3
- PostgreSQL (pg ~> 1.1)
- Puma 5.0 (Web Server)
- HTTParty (HTTP Client)
- Bootsnap (Boot Time Optimizer)

### Development & Testing
- RSpec Rails (~> 6.0)
- Factory Bot Rails (~> 6.2.0)
- Faker (Test Data Generation)
- Shoulda Matchers (~> 5.0.0)
- RSwag (API Documentation)
  - rswag-api
  - rswag-specs
  - rswag-ui
- Byebug (Debugger)
- Annotate (Model/Route Annotation)
- Spring (Development Server)
- Listen (~> 3.3)

### Testing Only
- WebMock (HTTP Request Stubbing)

## Design Decisions

1. Service Objects
   - Separates business logic from controllers
   - Improves maintainability and testing
   - Allows for easy modification of sorting/filtering logic

2. Database Optimization
   - Uses SQL for efficient sorting
   - Implements proper indexing
   - Minimizes memory usage

3. Code Organization
   - Clear separation of concerns
   - Modular design
   - Easy to extend and modify

