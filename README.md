# Car Recommendation API

A Ruby on Rails API that provides car recommendations based on user preferences and external AI-powered ranking scores. Designed to handle millions of records with optimized database performance.

## Overview

This API endpoint delivers personalized car recommendations by:
- Matching cars with user's preferred brands and price ranges
- Integrating AI-powered recommendation scores
- Implementing efficient database queries and caching strategies
- Sorting results by match quality, AI rank, and price
- Supporting pagination and filtering options
- Handling service resilience and data staleness

The system is built to:
- Scale efficiently with millions of database records
- Process complex filtering and sorting operations
- Handle external service interruptions gracefully
- Maintain responsive performance under load

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

## Setup

### Using Docker (Recommended)

1. Clone the repository

2. Build the application:
   ```bash
   ./car-market build
   ```

3. Start the application:
   ```bash
   ./car-market start
   ```

4. Setup the database:
   ```bash
   ./car-market db:setup
   ```

5. Run the test suite:
   ```bash
   ./car-market rspec
   ```

Available commands:
```bash
./car-market start      # Start the application
./car-market stop       # Stop all containers
./car-market clean      # Remove all containers and networks
./car-market console    # Access Rails console
./car-market rspec      # Run tests
./car-market db:migrate # Run database migrations
./car-market logs       # View application logs
```

### Manual Setup (Alternative)

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Setup database:
   ```bash
   rails db:create db:migrate
   ```

3. Run the test suite:
   ```bash
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

### Infrastructure
- Docker
- PostgreSQL 13 (Container)
- Docker Network for Service Communication

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

## AI-Powered Recommendations

The application integrates with an external AI recommendation service that provides personalized car suggestions. This service:

### Features
- Uses modern AI algorithms to rank cars based on user preferences
- Provides daily-updated recommendations for each user
- Returns rank scores between 0 and 1 (higher scores indicate stronger recommendations)
- Delivers the top 10 most relevant cars per user

### Integration Details
- Endpoint: `https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id=<USER_ID>`
- Response format:
```json
[
  {
    "car_id": 179,
    "rank_score": 0.945
  }
]
```

### Resilience Considerations
The application is designed to handle:
- Service unavailability
- API errors
- Stale data (updated once per day)
- Missing recommendations

### Caching Strategy
To optimize performance and handle service limitations:
- Recommendations are cached daily
- Fallback to database-only sorting when AI service is unavailable
- Efficient merging of AI recommendations with database queries
- Background job updates for recommendation data

### Integration with Core Features
The AI recommendations influence the car listing by:
1. Contributing to the sorting algorithm (after label matching)
2. Providing personalized rank scores in the API response
3. Complementing user's explicit preferences (brands and price range)

Example of how recommendations affect results:
```json
{
  "id": 179,
  "brand": {
    "id": 39,
    "name": "Volkswagen"
  },
  "model": "Derby",
  "price": 37230,
  "rank_score": 0.945,    // AI-provided score
  "label": "perfect_match" // Based on user preferences
}
```

## Design Decisions

1. Containerization
   - Docker-based development environment
   - Consistent environment across team members
   - Easy setup and deployment
   - Isolated dependencies

2. Service Objects
   - Separates business logic from controllers
   - Improves maintainability and testing
   - Allows for easy modification of sorting/filtering logic

3. Database Optimization
   - Uses SQL for efficient sorting
   - Implements proper indexing
   - Minimizes memory usage

4. Code Organization
   - Clear separation of concerns
   - Modular design
   - Easy to extend and modify

## Performance Considerations

This application was designed to simulate a system handling millions of database records, with a focus on database performance and scalability. Key optimizations include:

### Database Design
- Efficient indexing on frequently queried columns
- Optimized join operations between cars and brands
- Proper use of foreign keys for referential integrity
- Strategic use of database constraints

### Query Optimization
- Uses SQL-level filtering instead of Ruby-level filtering
- Implements database-side pagination
- Minimizes memory usage through lazy loading
- Leverages PostgreSQL's built-in full-text search capabilities

### Caching Strategy
- External recommendation scores are cached
- Brand-related queries are optimized
- Proper use of connection pooling
- Query result caching where appropriate

### Performance Testing
The application includes performance specs that simulate:
- Large datasets (millions of car records)
- Multiple concurrent users
- Complex filtering and sorting operations
- Heavy read operations with occasional writes

### Monitoring and Debugging
- SQL query logging for development
- Database performance metrics tracking
- Query execution plan analysis
- Memory usage monitoring

These optimizations ensure the application remains responsive and efficient even with:
- Large number of records
- Complex filtering operations
- Multiple concurrent users
- Frequent API requests

## Architecture Notes

### Container Structure
- Web Application (Ruby 2.7.2)
- PostgreSQL 13
- Custom networking for service communication
- Volume mapping for persistent data
- Environment-specific configurations

### Development Workflow
1. Build containers using `./car-market build`
2. Start services with `./car-market start`
3. Run tests via `./car-market rspec`
4. Access logs through `./car-market logs`
5. Clean up using `./car-market clean`

## API Usage Examples

After setting up the application and running the seeds (`./car-market db:setup`), you can interact with the API using the following examples:

### Basic Query
Get car recommendations for the seeded user:
```bash
curl "http://localhost:3000/api/v1/cars?user_id=1"
```

### Filter by Brand
Search for Volkswagen cars:
```bash
curl "http://localhost:3000/api/v1/cars?user_id=1&query=volkswagen"
```

### Filter by Price Range
Find cars between 30,000 and 45,000:
```bash
curl "http://localhost:3000/api/v1/cars?user_id=1&price_min=30000&price_max=45000"
```

### Pagination
View the second page of results:
```bash
curl "http://localhost:3000/api/v1/cars?user_id=1&page=2"
```

### Combined Filters
Search for Alfa Romeo cars under 40,000:
```bash
curl "http://localhost:3000/api/v1/cars?user_id=1&query=alfa&price_max=40000"
```

### Response Explanation
The API returns cars with the following information:
```json
{
  "id": 1,
  "brand": {
    "id": 1,
    "name": "Alfa Romeo"
  },
  "model": "Giulia",
  "price": 38000,
  "rank_score": 0.95,
  "label": "perfect_match"
}
```

Labels:
- `perfect_match`: Car matches both preferred brand and price range
- `good_match`: Car matches preferred brand only
- `null`: No specific match

Note: The seeded user (id: 1) has:
- Preferred brands: Alfa Romeo, Volkswagen
- Preferred price range: 35,000-40,000
- Email: example@mail.com

Rank scores are cached recommendations from an external service and range from 0 to 1, where higher scores indicate stronger recommendations.
