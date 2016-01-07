Machine Learning is not BS in Monitoring

https://medium.com/the-opsee-blog/machine-learning-in-monitoring-is-bs-134e362faee2

1. Ambiguity of the data - true point. It's impossible to build a single universal model that eats any data and alert when it's wrong. But it's possible to build different models for different cases with the help of humans.

2. Multiplicity of variables. It's true that mass of metrics doesn't make a lot of sense without context but adding context back and applying dimensionality reduction methods (SVD) allows to reduce mass into handful.

3. User experience . Machine learning is not a black box in general. Deep learning and gradient boosting models are black boxes but there are many interpretable models like regularized linear and logistic regression. They can give answers like "sales tomorrow will be higher than the previous Monday because it's a first working day after long holidays and sales are usually higher in that case"

4. Visualization. Traditional monitoring is built around dashboards and staring at graphs and it doesn't scale. At the same time there are different ways to present loads of data in visual form that makes sense to human (like MDS, T-SNE). ML could be used to produce better visualization to help humans understand what's going on.
